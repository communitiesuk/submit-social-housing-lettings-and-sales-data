require "rails_helper"

RSpec.describe CheckAnswersHelper do
  describe "Get answered questions total" do
    let!(:case_log) { FactoryBot.create(:case_log) }
    @form = Form.new(2021, 2022)
    subsection_pages = @form.pages_for_subsection("income_and_benefits")

    it "returns 0 if no questions are answered" do
      expect(get_answered_questions_total(subsection_pages, case_log)).to equal(0)
    end

    it "returns 1 if 1 question gets answered" do
      case_log["net_income"] = "123"
      expect(get_answered_questions_total(subsection_pages, case_log)).to equal(1)
    end
  end

  describe "Get total number of questions" do
    let!(:case_log) { FactoryBot.create(:case_log) }
    @form = Form.new(2021, 2022)
    subsection_pages = @form.pages_for_subsection("income_and_benefits")

    it "returns the total number of questions for a subsection" do
       expect(get_total_number_of_questions(subsection_pages)).to eq(4)
    end
  end
end
