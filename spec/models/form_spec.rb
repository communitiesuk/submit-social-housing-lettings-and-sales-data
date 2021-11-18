require "rails_helper"

RSpec.describe Form, type: :model do
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }
  let(:case_log) { FactoryBot.build(:case_log, :in_progress) }

  describe ".next_page" do
    let(:previous_page) { "person_1_age" }
    it "returns the next page given the previous" do
      expect(form.next_page(previous_page, case_log)).to eq("person_1_gender")
    end
  end

  describe "get subsection status" do
    let(:section) { "income_and_benefits" }

    it "returns not started if none of the questions in the subsection are answered" do
      status = form.subsection_status("income_and_benefits", case_log)
      expect(status).to eq(:not_started)
    end

    it "returns cannot start yet if the subsection is declaration" do
      status = form.subsection_status("declaration", case_log)
      expect(status).to eq(:cannot_start_yet)
    end

    it "returns in progress if some of the questions have been answered" do
      case_log["previous_postcode"] = "P0 5TT"
      status = form.subsection_status("local_authority", case_log)
      expect(status).to eq(:in_progress)
    end

    it "returns completed if all the questions in the subsection have been answered" do
      case_log["earnings"] = "value"
      case_log["incfreq"] = "Weekly"
      case_log["benefits"] = "All"
      case_log["hb"] = "Do not know"

      status = form.subsection_status("income_and_benefits", case_log)
      expect(status).to eq(:completed)
    end

    it "returns not started if the subsection is declaration and all the questions are completed" do
      status = form.subsection_status("declaration", completed_case_log)
      expect(status).to eq(:not_started)
    end

    it "sets the correct status for sections with conditional questions" do
      status = form.subsection_status("household_characteristics", conditional_section_complete_case_log)
      expect(status).to eq(:completed)
    end
  end

  describe ".first_page_for_subsection" do
    let(:subsection) { "household_characteristics" }
    it "returns the first page given  a subsection" do
      expect(form.first_page_for_subsection(subsection)).to eq("tenant_code")
    end
  end

  describe ".questions_for_subsection" do
    let(:subsection) { "income_and_benefits" }
    it "returns all questions for subsection" do
      result = form.questions_for_subsection(subsection)
      expect(result.length).to eq(4)
      expect(result.keys).to eq(%w[earnings incfreq benefits hb])
    end
  end

  describe "next_page_redirect_path" do
    let(:previous_page) { "net_income" }
    let(:last_previous_page) { "housing_benefit" }
    let(:previous_conditional_page) { "conditional_question" }

    it "returns a correct page path if there is no conditional routing" do
      expect(form.next_page_redirect_path(previous_page, case_log)).to eq("case_log_net_income_uc_proportion_path")
    end

    it "returns a check answers page if previous page is the last page" do
      expect(form.next_page_redirect_path(last_previous_page, case_log)).to eq("case_log_income_and_benefits_check_answers_path")
    end

    it "returns a correct page path if there is conditional routing" do
      case_log["preg_occ"] = "No"
      expect(form.next_page_redirect_path(previous_conditional_page, case_log)).to eq("case_log_conditional_question_no_page_path")
    end
  end
end
