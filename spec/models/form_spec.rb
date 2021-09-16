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
end
