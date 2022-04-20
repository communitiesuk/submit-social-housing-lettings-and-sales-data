require "rails_helper"

RSpec.describe ConditionalQuestionsHelper do
  let(:case_log) { FactoryBot.build(:case_log) }
  let(:page) { case_log.form.get_page("armed_forces") }

  describe "conditional questions for page" do
    let(:conditional_pages) { %w[leftreg] }

    it "returns the question keys of all conditional questions on the given page" do
      expect(conditional_questions_for_page(page)).to eq(conditional_pages)
    end
  end

  describe "find conditional question" do
    let(:question) { page.questions.find { |q| q.id == "armedforces" } }
    let(:answer_value) { 1 }

    it "returns the conditional question for a given answer option" do
      expect(find_conditional_question(page, question, answer_value).id).to eq("leftreg")
    end
  end

  describe "display question key div" do
    let(:conditional_question) { page.questions.find { |q| q.id == "leftreg" } }

    it "returns a non visible div for conditional questions" do
      expect(display_question_key_div(page, conditional_question)).to match("style='display:none;'")
    end

    it "returns a visible div for questions" do
      expect(display_question_key_div(page, page.questions.first)).not_to match("style='display:none;'")
    end
  end
end
