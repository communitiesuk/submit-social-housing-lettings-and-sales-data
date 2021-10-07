require "rails_helper"

RSpec.describe CheckAnswersHelper do
  let(:case_log) { FactoryBot.create(:case_log) }
  let(:form) { Form.new(2021, 2022) }
  let(:subsection) { "income_and_benefits" }

  describe "Get answered questions total" do
    it "returns 0 if no questions are answered" do
      expect(total_answered_questions(subsection, case_log)).to equal(0)
    end

    it "returns 1 if 1 question gets answered" do
      case_log["net_income"] = "123"
      expect(total_answered_questions(subsection, case_log)).to equal(1)
    end
  end

  describe "Get total number of questions" do
    it "returns the total number of questions for a subsection" do
      expect(total_number_of_questions(subsection, case_log)).to eq(4)
    end
  end
end
