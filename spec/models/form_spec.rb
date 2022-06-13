require "rails_helper"

RSpec.describe Form, type: :model do
  let(:case_log) { FactoryBot.build(:case_log, :in_progress) }
  let(:form) { case_log.form }
  let(:completed_case_log) { FactoryBot.build(:case_log, :completed) }
  let(:conditional_section_complete_case_log) { FactoryBot.build(:case_log, :conditional_section_complete) }

  describe ".next_page" do
    let(:previous_page) { form.get_page("person_1_age") }
    let(:value_check_previous_page) { form.get_page("net_income_value_check") }

    it "returns the next page given the previous" do
      expect(form.next_page(previous_page, case_log)).to eq("person_1_gender")
    end

    context "when the current page is a value check page" do
      before do
        case_log.incfreq = 1
        case_log.earnings = 140
        case_log.ecstat1 = 1
      end

      it "returns the previous page if answer is `No` and the page is routed to" do
        case_log.net_income_value_check = 1
        expect(form.next_page(value_check_previous_page, case_log)).to eq("net_income")
      end

      it "returns the next page if answer is `Yes` answer and the page is routed to" do
        case_log.net_income_value_check = 0
        expect(form.next_page(value_check_previous_page, case_log)).to eq("net_income_uc_proportion")
      end
    end
  end

  describe ".previous_page" do
    context "when the current page is not a value check page" do
      let!(:subsection) { form.get_subsection("conditional_question") }
      let!(:page_ids) { subsection.pages.map(&:id) }

      before do
        case_log.preg_occ = 2
      end

      it "returns the previous page if the page is routed to" do
        page_index = page_ids.index("conditional_question_no_second_page")
        expect(form.previous_page(page_ids, page_index, case_log)).to eq("conditional_question_no_page")
      end

      it "returns the page before the previous one if the previous page is not routed to" do
        page_index = page_ids.index("conditional_question_no_page")
        expect(form.previous_page(page_ids, page_index, case_log)).to eq("conditional_question")
      end
    end
  end

  describe "next_page_redirect_path" do
    let(:previous_page) { form.get_page("net_income") }
    let(:last_previous_page) { form.get_page("housing_benefit") }
    let(:previous_conditional_page) { form.get_page("conditional_question") }

    it "returns a correct page path if there is no conditional routing" do
      expect(form.next_page_redirect_path(previous_page, case_log)).to eq("case_log_net_income_uc_proportion_path")
    end

    it "returns a check answers page if previous page is the last page" do
      expect(form.next_page_redirect_path(last_previous_page, case_log)).to eq("case_log_income_and_benefits_check_answers_path")
    end

    it "returns a correct page path if there is conditional routing" do
      case_log["preg_occ"] = 2
      expect(form.next_page_redirect_path(previous_conditional_page, case_log)).to eq("case_log_conditional_question_no_page_path")
    end
  end

  describe "next_incomplete_section_redirect_path" do
    let(:case_log) { FactoryBot.build(:case_log, :in_progress) }
    let(:subsection) { form.get_subsection("household_characteristics") }
    let(:later_subsection) { form.get_subsection("declaration") }

    context "when a user is on the check answers page for a subsection" do
      def answer_household_needs(case_log)
        case_log.armedforces = 3
        case_log.illness = 0
        case_log.housingneeds_a = 1
        case_log.la = "E06000014"
        case_log.illness_type_1 = 1
      end

      def answer_tenancy_information(case_log)
        case_log.tenancy_code = "1234"
      end

      def answer_property_information(case_log)
        case_log.wchair = "No"
      end

      def answer_conditional_question(case_log)
        case_log.preg_occ = "No"
        case_log.cbl = "No"
      end

      def answer_income_and_benefits(case_log)
        case_log.earnings = 30_000
        case_log.incfreq = 3
        case_log.benefits = "Some"
        case_log.hb = "Tenant prefers not to say"
      end

      def answer_rent_and_charges(case_log)
        case_log.period = "Every 2 weeks"
        case_log.brent = 650
        case_log.scharge = 0
        case_log.pscharge = 0
        case_log.supcharg = 0
        case_log.tcharge = 650
      end

      def answer_local_authority(case_log)
        case_log.layear = "1 year but under 2 years"
        case_log.waityear = "Less than 1 year"
        case_log.postcode_full = "NW1 5TY"
        case_log.reason = "Permanently decanted from another property owned by this landlord"
        case_log.ppostcode_full = "SE2 6RT"
        case_log.mrcdate = Time.zone.parse("03/11/2019")
      end

      before do
        case_log.tenancycode = "123"
        case_log.age1 = 35
        case_log.sex1 = "M"
        case_log.ecstat1 = 0
        case_log.hhmemb = 2
        case_log.relat2 = "P"
        case_log.sex2 = "F"
        case_log.ecstat2 = 1
      end

      it "returns the first page of the next incomplete subsection if the subsection is not in progress" do
        expect(form.next_incomplete_section_redirect_path(subsection, case_log)).to eq("armed-forces")
      end

      it "returns the check answers page of the next incomplete subsection if the subsection is already in progress" do
        case_log.armedforces = "No"
        case_log.illness = "No"
        expect(form.next_incomplete_section_redirect_path(subsection, case_log)).to eq("household-needs/check-answers")
      end

      it "returns the first page of the next incomplete subsection (skipping completed subsections)" do
        answer_household_needs(case_log)
        expect(form.next_incomplete_section_redirect_path(subsection, case_log)).to eq("tenancy-code")
      end

      it "returns the declaration section for a completed case log" do
        expect(form.next_incomplete_section_redirect_path(subsection, completed_case_log)).to eq("declaration")
      end

      it "returns the next incomplete section by cycling back around if next subsections are completed" do
        expect(form.next_incomplete_section_redirect_path(later_subsection, case_log)).to eq("armed-forces")
      end

      it "returns the declaration section if all sections are complete but the case log is in progress" do
        answer_household_needs(case_log)
        answer_tenancy_information(case_log)
        answer_property_information(case_log)
        answer_conditional_question(case_log)
        answer_income_and_benefits(case_log)
        answer_rent_and_charges(case_log)
        answer_local_authority(case_log)

        expect(form.next_incomplete_section_redirect_path(subsection, case_log)).to eq("declaration")
      end
    end
  end

  describe "invalidated_page_questions" do
    context "when dependencies are not met" do
      let(:expected_invalid) { %w[condition_effects cbl conditional_question_no_second_question net_income_value_check dependent_question offered layear declaration] }

      it "returns an array of question keys whose pages conditions are not met" do
        expect(form.invalidated_page_questions(case_log).map(&:id).uniq).to eq(expected_invalid)
      end
    end

    context "with two pages having the same question and only one has dependencies met" do
      let(:expected_invalid) { %w[condition_effects cbl conditional_question_no_second_question net_income_value_check dependent_question offered layear declaration] }

      it "returns an array of question keys whose pages conditions are not met" do
        case_log["preg_occ"] = "No"
        expect(form.invalidated_page_questions(case_log).map(&:id).uniq).to eq(expected_invalid)
      end
    end

    context "when a page is marked as `derived` and `depends_on: false`" do
      let(:case_log) { FactoryBot.build(:case_log, :in_progress, startdate: Time.utc(2023, 2, 2, 10, 36, 49)) }

      it "does not count it's questions as invalidated" do
        expect(form.enabled_page_questions(case_log).map(&:id).uniq).to include("tshortfall_known")
      end

      it "does not route to the page" do
        expect(form.invalidated_pages(case_log).map(&:id)).to include("outstanding_amount_known")
      end
    end
  end
end
