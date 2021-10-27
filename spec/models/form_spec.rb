require "rails_helper"

RSpec.describe Form, type: :model do
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }

  describe ".next_page" do
    let(:previous_page) { "person_1_age" }
    it "returns the next page given the previous" do
      expect(form.next_page(previous_page)).to eq("person_1_gender")
    end
  end

  describe ".first_page_for_subsection" do
    let(:subsection) { "household_characteristics" }
    it "returns the first page given  a subsection" do
      expect(form.first_page_for_subsection(subsection)).to eq("tenant_code")
    end
  end

  describe ".previous_page" do
    context "given a page in the middle of a subsection" do
      let(:current_page) { "person_1_age" }
      it "returns the previous page given the current" do
        expect(form.previous_page(current_page)).to eq("tenant_code")
      end
    end

    context "given the first page in a subsection" do
      let(:current_page) { "tenant_code" }
      it "returns empty string" do
        expect(form.previous_page(current_page)).to be_nil
      end
    end
  end

  describe ".questions_for_subsection" do
    let(:subsection) { "income_and_benefits" }
    it "returns all questions for subsection" do
      result = form.questions_for_subsection(subsection)
      expect(result.length).to eq(4)
      expect(result.keys).to eq(%w[net_income net_income_frequency net_income_uc_proportion housing_benefit])
    end
  end
end
