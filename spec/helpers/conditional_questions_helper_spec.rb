require "rails_helper"

RSpec.describe ConditionalQuestionsHelper do
  let(:form) { Form.new(2021, 2022) }
  let(:page_key) { "armed_forces" }
  let(:page) { form.all_pages[page_key] }

  describe "conditional questions for page" do
    let(:conditional_pages) { ["armed_forces_active", "armed_forces_injured"] }

    it "returns the question keys of all conditional questions on the given page" do
      expect(conditional_questions_for_page(page)).to eq(conditional_pages)
    end
  end
end
