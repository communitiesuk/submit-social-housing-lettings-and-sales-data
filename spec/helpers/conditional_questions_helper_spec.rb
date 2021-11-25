require "rails_helper"

RSpec.describe ConditionalQuestionsHelper do
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }
  let(:page) { form.get_page("armed_forces") }

  describe "conditional questions for page" do
    let(:conditional_pages) { %w[leftreg reservist] }

    it "returns the question keys of all conditional questions on the given page" do
      expect(conditional_questions_for_page(page)).to eq(conditional_pages)
    end
  end

  describe "display question key div" do
    let(:conditional_question) { page.questions.find { |q| q.id == "reservist" } }

    it "returns a non visible div for conditional questions" do
      expect(display_question_key_div(page, conditional_question)).to match("style='display:none;'")
    end

    it "returns a visible div for questions" do
      expect(display_question_key_div(page, page.questions.first)).not_to match("style='display:none;'")
    end
  end
end
