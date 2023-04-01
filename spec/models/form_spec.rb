require "rails_helper"

RSpec.describe Form, type: :model do
  around do |example|
    Timecop.freeze(Time.zone.local(2022, 1, 1)) do
      Singleton.__init__(FormHandler)
      example.run
    end
    Timecop.return
    Singleton.__init__(FormHandler)
  end

  let(:user) { FactoryBot.build(:user) }
  let(:lettings_log) { FactoryBot.build(:lettings_log, :in_progress) }
  let(:form) { lettings_log.form }
  let(:completed_lettings_log) { FactoryBot.build(:lettings_log, :completed) }
  let(:conditional_section_complete_lettings_log) { FactoryBot.build(:lettings_log, :conditional_section_complete) }

  describe ".next_page" do
    let(:previous_page_id) { form.get_page("person_1_age") }
    let(:value_check_previous_page) { form.get_page("net_income_value_check") }

    it "returns the next page given the previous" do
      expect(form.next_page_id(previous_page_id, lettings_log, user)).to eq("person_1_gender")
    end

    context "when the current page is a value check page" do
      before do
        lettings_log.incfreq = 1
        lettings_log.earnings = 140
        lettings_log.ecstat1 = 1
      end

      it "returns the previous page if answer is `No` and the page is routed to" do
        lettings_log.net_income_value_check = 1
        expect(form.next_page_id(value_check_previous_page, lettings_log, user)).to eq("net_income")
      end

      it "returns the next page if answer is `Yes` answer and the page is routed to" do
        lettings_log.net_income_value_check = 0
        expect(form.next_page_id(value_check_previous_page, lettings_log, user)).to eq("net_income_uc_proportion")
      end
    end
  end

  describe ".previous_page" do
    context "when the current page is not a value check page" do
      let!(:subsection) { form.get_subsection("conditional_question") }

      before do
        lettings_log.preg_occ = 2
      end

      it "returns the previous page if the page is routed to" do
        page = subsection.pages.find { |p| p.id == "conditional_question_no_second_page" }
        expect(form.previous_page_id(page, lettings_log, user)).to eq("conditional_question_no_page")
      end

      it "returns the page before the previous one if the previous page is not routed to" do
        page = subsection.pages.find { |p| p.id == "conditional_question_no_page" }
        expect(form.previous_page_id(page, lettings_log, user)).to eq("conditional_question")
      end
    end
  end

  describe "next_page_redirect_path" do
    let(:previous_page_id) { form.get_page("net_income") }
    let(:last_previous_page) { form.get_page("housing_benefit") }
    let(:previous_conditional_page) { form.get_page("conditional_question") }

    it "returns a correct page path if there is no conditional routing" do
      expect(form.next_page_redirect_path(previous_page_id, lettings_log, user)).to eq("lettings_log_net_income_uc_proportion_path")
    end

    it "returns a check answers page if previous page is the last page" do
      expect(form.next_page_redirect_path(last_previous_page, lettings_log, user)).to eq("lettings_log_income_and_benefits_check_answers_path")
    end

    it "returns a correct page path if there is conditional routing" do
      lettings_log["preg_occ"] = 2
      expect(form.next_page_redirect_path(previous_conditional_page, lettings_log, user)).to eq("lettings_log_conditional_question_no_page_path")
    end
  end

  describe "next_incomplete_section_redirect_path" do
    let(:lettings_log) { FactoryBot.build(:lettings_log, :in_progress) }
    let(:subsection) { form.get_subsection("household_characteristics") }
    let(:later_subsection) { form.get_subsection("declaration") }

    context "when a user is on the check answers page for a subsection" do
      def answer_household_needs(lettings_log)
        lettings_log.armedforces = 3
        lettings_log.illness = 0
        lettings_log.housingneeds_a = 1
        lettings_log.la = "E06000014"
        lettings_log.illness_type_1 = 1
      end

      def answer_tenancy_information(lettings_log)
        lettings_log.tenancycode = "1234"
      end

      def answer_property_information(lettings_log)
        lettings_log.postcode_known = 1
        lettings_log.wchair = "No"
      end

      def answer_conditional_question(lettings_log)
        lettings_log.preg_occ = "No"
        lettings_log.cbl = "No"
      end

      def answer_income_and_benefits(lettings_log)
        lettings_log.earnings = 30_000
        lettings_log.incfreq = 3
        lettings_log.benefits = "Some"
        lettings_log.hb = "Tenant prefers not to say"
      end

      def answer_rent_and_charges(lettings_log)
        lettings_log.period = "Every 2 weeks"
        lettings_log.brent = 650
        lettings_log.scharge = 0
        lettings_log.pscharge = 0
        lettings_log.supcharg = 0
        lettings_log.tcharge = 650
      end

      def answer_local_authority(lettings_log)
        lettings_log.layear = "1 year but under 2 years"
        lettings_log.waityear = "Less than 1 year"
        lettings_log.postcode_full = "NW1 5TY"
        lettings_log.reason = "Permanently decanted from another property owned by this landlord"
        lettings_log.ppostcode_full = "SE2 6RT"
        lettings_log.mrcdate = Time.zone.parse("03/11/2019")
      end

      before do
        lettings_log.tenancycode = "123"
        lettings_log.age1 = 35
        lettings_log.sex1 = "M"
        lettings_log.ecstat1 = 0
        lettings_log.hhmemb = 2
        lettings_log.relat2 = "P"
        lettings_log.sex2 = "F"
        lettings_log.ecstat2 = 1
        lettings_log.needstype = 1
      end

      it "returns the first page of the next incomplete subsection if the subsection is not in progress" do
        expect(form.next_incomplete_section_redirect_path(subsection, lettings_log)).to eq("armed-forces")
      end

      it "returns the check answers page of the next incomplete subsection if the subsection is already in progress" do
        lettings_log.armedforces = "No"
        lettings_log.illness = "No"
        expect(form.next_incomplete_section_redirect_path(subsection, lettings_log)).to eq("household-needs/check-answers")
      end

      it "returns the first page of the next incomplete subsection (skipping completed subsections, and pages that are not routed to)" do
        answer_household_needs(lettings_log)
        expect(form.next_incomplete_section_redirect_path(subsection, lettings_log)).to eq("property-postcode")
      end

      it "returns the declaration section for a completed lettings log" do
        expect(form.next_incomplete_section_redirect_path(subsection, completed_lettings_log)).to eq("declaration")
      end

      it "returns the next incomplete section by cycling back around if next subsections are completed" do
        expect(form.next_incomplete_section_redirect_path(later_subsection, lettings_log)).to eq("armed-forces")
      end

      it "returns the declaration section if all sections are complete but the lettings log is in progress" do
        answer_household_needs(lettings_log)
        answer_tenancy_information(lettings_log)
        answer_property_information(lettings_log)
        answer_conditional_question(lettings_log)
        answer_income_and_benefits(lettings_log)
        answer_rent_and_charges(lettings_log)
        answer_local_authority(lettings_log)

        expect(form.next_incomplete_section_redirect_path(subsection, lettings_log)).to eq("declaration")
      end
    end

    context "when no pages or questions in the next subsection are routed to" do
      let(:subsection) { form.get_subsection("setup") }

      around do |example|
        FormHandler.instance.use_real_forms!

        example.run

        FormHandler.instance.use_fake_forms!
      end

      it "finds the path to the section after" do
        lettings_log.startdate = Time.zone.local(2022, 9, 1)
        lettings_log.renewal = 1
        lettings_log.needstype = 2
        lettings_log.postcode_known = 0
        expect(form.next_incomplete_section_redirect_path(subsection, lettings_log)).to eq("joint")
      end
    end
  end

  describe "#reset_not_routed_questions_and_invalid_answers" do
    around do |example|
      Singleton.__init__(FormHandler)
      Timecop.freeze(now) do
        FormHandler.instance.use_real_forms!
        example.run
      end
      FormHandler.instance.use_fake_forms!
    end

    let(:now) { Time.zone.local(2023, 5, 5) }

    context "when there are multiple radio questions for attribute X" do
      context "and attribute Y is changed such that a different question for X is routed to" do
        let(:log) { FactoryBot.create(:lettings_log, :about_completed, :sheltered_housing, startdate: now, renewal: 0, prevten:) }

        context "and the value of X remains valid" do
          let(:prevten) { 36 }

          it "the value of this attribute is not cleared" do
            log.renewal = 1
            log.form.reset_not_routed_questions_and_invalid_answers(log)
            expect(log.prevten).to be 36
          end
        end

        context "and the value of X is now invalid" do
          let(:prevten) { 30 }

          it "the value of this attribute is cleared" do
            log.renewal = 1
            log.form.reset_not_routed_questions_and_invalid_answers(log)
            expect(log.prevten).to be nil
          end
        end
      end
    end

    context "when there is one radio question for attribute X" do
      context "and the start date or sale date is changed such that the collection year changes and there are different options" do
        let(:log) { FactoryBot.create(:lettings_log, :about_completed, :sheltered_housing, startdate: now, sheltered:) }

        context "and the value of X remains valid" do
          let(:sheltered) { 2 }

          it "the value of this attribute is not cleared" do
            log.update!(startdate: Time.zone.local(2023, 1, 1))
            expect(log.sheltered).to be 2
          end
        end

        context "and the value of X is now invalid" do
          let(:sheltered) { 5 }

          it "the value of this attribute is cleared" do
            log.update!(startdate: Time.zone.local(2023, 1, 1))
            expect(log.sheltered).to be nil
          end
        end
      end
    end

    context "when there is one free user input question for an attribute X" do
      let(:log) { FactoryBot.create(:sales_log, :shared_ownership_setup_complete, staircase: 1, stairbought: 25) }

      context "and attribute Y is changed such that it is no longer routed to" do
        it "the value of this attribute is cleared" do
          expect(log.stairbought).to be 25
          log.staircase = 2
          log.form.reset_not_routed_questions_and_invalid_answers(log)
          expect(log.stairbought).to be nil
        end
      end
    end

    context "when there are multiple free user input questions for attribute X" do
      context "and attribute Y is changed such that a different question for X is routed to" do
        let(:log) { FactoryBot.create(:sales_log, :saledate_today, :shared_ownership, :privacy_notice_seen, jointpur: 1, jointmore: 2, hholdcount: expected_hholdcount) }
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
          expect(log.value).to be nil
        end
      end
    end

    context "when a value is changed such that a checkbox question is no longer routed to" do
      let(:log) { FactoryBot.create(:lettings_log, :about_completed, startdate: now, reasonpref: 1, rp_homeless: 1, rp_medwel: 1, rp_hardship: 1) }

      it "all attributes relating to that checkbox question are cleared" do
        expect(log.rp_homeless).to be 1
        log.reasonpref = 2
        log.form.reset_not_routed_questions_and_invalid_answers(log)
        expect(log.rp_homeless).to be nil
        expect(log.rp_medwel).to be nil
        expect(log.rp_hardship).to be nil
      end
    end

    context "when an attribute is derived, but no questions for that attribute are routed to" do
      let(:log) { FactoryBot.create(:sales_log, :outright_sale_setup_complete, value: 200_000) }

      it "the value of this attribute is not cleared" do
        expect(log.deposit).to be nil
        log.update!(mortgageused: 2)
        expect(log.form.questions.any? { |q| q.id == "deposit" && q.page.routed_to?(log, nil) }).to be false
        expect(log.deposit).not_to be nil
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
        expect(log.location_id).not_to be nil
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
      expect(form.pages.count).to eq(18)
      expect(form.pages.first.id).to eq("organisation")
      expect(form.questions.count).to eq(19)
      expect(form.questions.first.id).to eq("owning_organisation_id")
      expect(form.start_date).to eq(Time.zone.parse("2022-04-01"))
      expect(form.end_date).to eq(Time.zone.parse("2023-06-07"))
      expect(form.unresolved_log_redirect_page_id).to eq(nil)
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
