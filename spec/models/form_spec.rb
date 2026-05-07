require "rails_helper"

RSpec.describe Form, type: :model do
  let(:user) { FactoryBot.build(:user) }
  let(:lettings_log) { FactoryBot.build(:lettings_log, :in_progress) }
  let(:form) { lettings_log.form }
  let(:completed_lettings_log) { FactoryBot.build(:lettings_log, :completed) }

  describe ".next_page" do
    let(:previous_page_id) { form.get_page("renewal") }
    let(:value_check_previous_page) { form.get_page("net_income_value_check") }

    it "returns the next page, given the previous" do
      expect(form.next_page_id(previous_page_id, lettings_log, user)).to eq("tenancy_start_date")
    end

    context "when the next page has more than one question" do
      let(:previous_page_id) { form.get_page("tenancy_start_date") }
      let(:next_page) { form.get_page("rent_type") }

      context "when every question on the next page returns `true` from its `skip_question_in_form_flow?` method" do
        before do
          allow(next_page.questions.first).to receive(:skip_question_in_form_flow?)
            .with(lettings_log)
            .and_return(true)
          allow(next_page.questions.second).to receive(:skip_question_in_form_flow?)
            .with(lettings_log)
            .and_return(true)
        end

        it "returns the page after next, given the previous" do
          expect(form.next_page_id(previous_page_id, lettings_log, user)).to eq("tenant_code")
        end
      end

      context "when at least question on the next page returns `false` from its `skip_question_in_form_flow?` method" do
        before do
          allow(next_page.questions.first).to receive(:skip_question_in_form_flow?)
            .with(lettings_log)
            .and_return(true)
          allow(next_page.questions.second).to receive(:skip_question_in_form_flow?)
            .with(lettings_log)
            .and_return(false)
        end

        it "returns the next page, given the previous" do
          expect(form.next_page_id(previous_page_id, lettings_log, user)).to eq("rent_type")
        end
      end
    end

    context "when the current page is a value check page" do
      before do
        lettings_log.hhmemb = 1
        lettings_log.incfreq = 1
        lettings_log.earnings = 140
        lettings_log.ecstat1 = 1
      end

      it "returns the previous page if answer is `No` and the page is routed to" do
        lettings_log.net_income_value_check = 1
        expect(form.next_page_id(value_check_previous_page, lettings_log, user)).to eq(:check_answers)
      end

      it "returns the next page if answer is `Yes` answer and the page is routed to" do
        lettings_log.net_income_value_check = 0
        expect(form.next_page_id(value_check_previous_page, lettings_log, user)).to eq(:check_answers)
      end
    end
  end

  describe ".previous_page" do
    context "when the current page is not a value check page" do
      let!(:subsection) { form.get_subsection("setup") }

      it "returns the previous page if the page is routed to" do
        page = form.get_page("rent_type")
        expect(form.previous_page_id(page, lettings_log, user)).to eq("tenancy_start_date")
      end

      it "returns the page before the previous one if the previous page is not routed to" do
        lettings_log.needstype = 2
        page = form.get_page("renewal")
        expect(form.previous_page_id(page, lettings_log, user)).to eq("scheme")
      end
    end
  end

  describe "next_page_redirect_path" do
    let(:previous_page_id) { form.get_page("renewal") }
    let(:last_previous_page) { form.get_page("property_reference") }
    let(:previous_conditional_page) { form.get_page("needs_type") }

    it "returns a correct page path if there is no conditional routing" do
      expect(form.next_page_redirect_path(previous_page_id, lettings_log, user)).to eq("lettings_log_tenancy_start_date_path")
    end

    it "returns a check answers page if previous page is the last page" do
      expect(form.next_page_redirect_path(last_previous_page, lettings_log, user)).to eq("lettings_log_declaration_path")
    end

    it "returns a correct page path if there is conditional routing" do
      lettings_log.needstype = 2
      expect(form.next_page_redirect_path(previous_conditional_page, lettings_log, user)).to eq("lettings_log_scheme_path")
    end
  end

  describe "next_incomplete_section_redirect_path" do
    let(:lettings_log) { FactoryBot.create(:lettings_log, :setup_completed) }
    let(:subsection) { form.get_subsection("setup") }
    let(:later_subsection) { form.get_subsection("income_and_benefits") }

    context "when a user is on the check answers page for a subsection" do
      it "returns the first page of the next incomplete subsection if the subsection is not in progress" do
        expect(form.next_incomplete_section_redirect_path(subsection, lettings_log)).to eq("first-time-property-let-as-social-housing")
      end

      it "returns the check answers page of the next incomplete subsection if the subsection is already in progress" do
        lettings_log.first_time_property_let_as_social_housing = 1
        expect(form.next_incomplete_section_redirect_path(subsection, lettings_log)).to eq("property-information/check-answers")
      end

      it "returns the next incomplete section by cycling back around if next subsections are completed" do
        expect(form.next_incomplete_section_redirect_path(later_subsection, lettings_log)).to eq("first-time-property-let-as-social-housing")
      end
    end

    context "when a log has status in progress but all subsections are complete" do
      let(:lettings_log) { build(:lettings_log, :completed, status: "in_progress") }
      let(:subsection) { form.get_subsection("setup") }

      it "does not raise a Stack Error" do
        expect { form.next_incomplete_section_redirect_path(subsection, lettings_log) }.not_to raise_error
      end
    end
  end

  describe "#reset_not_routed_questions_and_invalid_answers" do
    include CollectionTimeHelper

    let(:now) { current_collection_start_date }

    context "when there are multiple radio questions for attribute X" do
      context "and attribute Y is changed such that a different question for X is routed to" do
        let(:log) { FactoryBot.create(:lettings_log, :setup_completed, :sheltered_housing, startdate: now, renewal: 0, prevten:) }

        context "and the value of X remains valid" do
          let(:prevten) { 35 }

          it "the value of this attribute is not cleared" do
            log.renewal = 1
            log.form.reset_not_routed_questions_and_invalid_answers(log)
            expect(log.prevten).to be 35
          end
        end

        context "and the value of X is now invalid" do
          let(:prevten) { 30 }

          it "the value of this attribute is cleared" do
            log.renewal = 1
            log.form.reset_not_routed_questions_and_invalid_answers(log)
            expect(log.prevten).to be_nil
          end
        end
      end
    end

    context "when there is one radio question for attribute X" do
      context "and the start date or sale date is changed such that the collection year changes and there are different options" do
        let(:log) { FactoryBot.create(:lettings_log, :setup_completed, :sheltered_housing, startdate: now, sheltered:) }
        let(:previous_year_date) { previous_collection_start_date + 1.month }

        context "and the value of X remains valid" do
          let(:sheltered) { 2 }

          it "the value of this attribute is not cleared" do
            log.update!(startdate: previous_year_date)
            expect(log.sheltered).to be 2
          end
        end

        context "and the value of X is now invalid" do
          let(:sheltered) { 5 }

          it "the value of this attribute is cleared" do
            log.update!(startdate: previous_year_date)
            expect(log.sheltered).to be_nil
          end
        end
      end
    end

    context "when there is one free user input question for an attribute X" do
      let(:log) { FactoryBot.create(:sales_log, :shared_ownership_setup_complete, staircase: 1, stairbought: 25) }

      context "and attribute Y is changed such that it is no longer routed to" do
        it "the value of this attribute is cleared" do
          expect(log.stairbought).to eq 25
          log.staircase = 2
          log.form.reset_not_routed_questions_and_invalid_answers(log)
          expect(log.stairbought).to be_nil
        end
      end
    end

    context "when there are multiple free user input questions for attribute X" do
      context "and attribute Y is changed such that a different question for X is routed to" do
        let(:log) { FactoryBot.create(:sales_log, :shared_ownership_setup_complete, staircase: 2, jointpur: 1, jointmore: 2, hholdcount: expected_hholdcount) }
        let(:expected_hholdcount) { 2 }

        it "the value of this attribute is not cleared" do
          log.jointpur = 2
          log.form.reset_not_routed_questions_and_invalid_answers(log)
          expect(log.hholdcount).to eq expected_hholdcount
        end
      end

      context "and attribute Y is changed such that no questions for X are routed to" do
        let(:log) { FactoryBot.create(:sales_log, :shared_ownership_setup_complete, value: initial_value) }
        let(:initial_value) { 200_000.to_d }

        it "the value of this attribute is cleared" do
          expect(log.value).to eq initial_value
          log.ownershipsch = 2
          log.form.reset_not_routed_questions_and_invalid_answers(log)
          expect(log.value).to be_nil
        end
      end
    end

    context "when a value is changed such that a checkbox question is no longer routed to" do
      let(:log) { FactoryBot.create(:lettings_log, :setup_completed, startdate: now, reasonpref: 1, rp_homeless: 1, rp_medwel: 1, rp_hardship: 1) }

      it "all attributes relating to that checkbox question are cleared" do
        expect(log.rp_homeless).to be 1
        log.reasonpref = 2
        log.form.reset_not_routed_questions_and_invalid_answers(log)
        expect(log.rp_homeless).to be_nil
        expect(log.rp_medwel).to be_nil
        expect(log.rp_hardship).to be_nil
      end
    end

    context "when a value is changed such that a radio and free input questions are no longer routed to" do
      let(:log) { FactoryBot.create(:lettings_log, :completed, startdate: now, hhmemb: 2, details_known_2: 0, sexrab2: "M", relat2: "P", age2_known: 0, age2: 32, ecstat2: 6) }

      it "all attributes relating to that checkbox question are cleared" do
        expect(log.hhmemb).to be 2
        expect(log.details_known_2).to be 0
        expect(log.sexrab2).to eq("M")
        expect(log.relat2).to eq("P")
        expect(log.age2_known).to be 0
        expect(log.age2).to be 32
        expect(log.ecstat2).to be 6

        log.update!(hhmemb: 1)
        expect(log.details_known_2).to be_nil
        expect(log.sexrab2).to be_nil
        expect(log.relat2).to be_nil
        expect(log.age2_known).to be_nil
        expect(log.age2).to be_nil
        expect(log.ecstat2).to be_nil
      end
    end

    context "when an attribute is derived, but no questions for that attribute are routed to" do
      let(:log) { FactoryBot.create(:lettings_log, :completed, startdate: now, unittype_gn: 2) }

      it "the value of this attribute is not cleared" do
        expect(log.is_bedsit?).to be true
        expect(log.form.questions.any? { |q| q.id == "beds" && q.page.routed_to?(log, nil) }).to be false
        expect(log.form.questions.any? { |q| q.id == "beds" && q.derived?(log) }).to be true
        log.beds = 1
        log.form.reset_not_routed_questions_and_invalid_answers(log)
        expect(log.beds).to eq 1
      end
    end

    context "when an attribute is related to a callback question with no set answer options, and no questions for that attribute are routed to" do
      let(:location) { FactoryBot.create(:location) }
      let(:log) { FactoryBot.create(:lettings_log, :startdate_today) }

      # Pages::PropertyPostcode and questions inside have been removed from form. do we not want to delete and migration delete_column?
      it "the value of this attribute is not cleared" do
        expect(log.form.questions.find { |q| q.id == "location_id" }.answer_options.keys).to be_empty
        log.location_id = location.id
        log.form.reset_not_routed_questions_and_invalid_answers(log)
        expect(log.location_id).not_to be_nil
      end
    end
  end

  describe "when creating a sales log", :aggregate_failures do
    it "creates a valid sales form" do
      sections = []
      form = described_class.new(nil, 2022, sections, "sales")
      expect(form.type).to eq("sales")
      expect(form.name).to eq("2022_2023_sales")
      expect(form.setup_sections.count).to eq(1)
      expect(form.setup_sections[0].class).to eq(Form::Sales::Sections::Setup)
      expect(form.sections.count).to eq(1)
      expect(form.sections[0].class).to eq(Form::Sales::Sections::Setup)
      expect(form.subsections.count).to eq(1)
      expect(form.subsections.first.id).to eq("setup")
      expect(form.start_date).to eq(Time.zone.parse("2022-04-01"))
      expect(form.new_logs_end_date).to eq(Time.zone.parse("2023-11-20"))
      expect(form.edit_end_date).to eq(Time.zone.parse("2023-11-20"))
      expect(form.submission_deadline).to eq(Time.zone.parse("2023-06-09"))
      expect(form.unresolved_log_redirect_page_id).to be_nil
    end

    it "can correctly define sections in the sales form" do
      sections = [Form::Sales::Sections::PropertyInformation]
      form = described_class.new(nil, 2022, sections, "sales")
      expect(form.type).to eq("sales")
      expect(form.name).to eq("2022_2023_sales")
      expect(form.sections.count).to eq(2)
      expect(form.sections[1].class).to eq(Form::Sales::Sections::PropertyInformation)
    end
  end

  describe "when creating a lettings log", :aggregate_failures do
    it "creates a valid lettings form" do
      form = described_class.new("spec/fixtures/forms/2021_2022.json")
      expect(form.type).to eq("lettings")
      expect(form.name).to eq("2021_2022_lettings")
      expect(form.unresolved_log_redirect_page_id).to eq("tenancy_start_date")
    end
  end
end
