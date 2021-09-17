require "rails_helper"

RSpec.describe Form, type: :model do
  describe ".next_question" do
    let(:previous_question) { "tenant_age" }
    it "returns the next question given the previous" do
      expect(Form.next_question(previous_question)).to eq("tenant_gender")
    end
  end

  describe ".first_question_for_subsection" do
    let(:subsection) { "household_characteristics" }
    it "returns the next question given the previous" do
      expect(Form.first_question_for_subsection(subsection)).to eq("tenant_code")
    end
  end

  describe ".previous_question" do
    context "given a question in the middle of a subsection" do
      let(:current_question) { "tenant_age" }
      it "returns the previous question given the current" do
        expect(Form.previous_question(current_question)).to eq("tenant_code")
      end
    end

    context "given the first question in a subsection" do
      let(:current_question) { "tenant_code" }
      it "returns empty string" do
        expect(Form.previous_question(current_question)).to be_nil
      end
    end
  end
end
