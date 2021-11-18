require "rails_helper"

RSpec.describe TasklistHelper do
  let(:empty_case_log) { FactoryBot.build(:case_log) }
  let(:case_log) { FactoryBot.build(:case_log, :in_progress) }
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }

  describe "get next incomplete section" do
    it "returns the first subsection name if it is not completed" do
      expect(get_next_incomplete_section(form, case_log)).to eq("household_characteristics")
    end

    it "returns the first subsection name if it is partially completed" do
      case_log["tenant_code"] = 123
      expect(get_next_incomplete_section(form, case_log)).to eq("household_characteristics")
    end
  end

  describe "get sections count" do
    it "returns the total of sections if no status is given" do
      expect(get_subsections_count(form, empty_case_log)).to eq(9)
    end

    it "returns 0 sections for completed sections if no sections are completed" do
      expect(get_subsections_count(form, empty_case_log, :completed)).to eq(0)
    end

    it "returns the number of not started sections" do
      expect(get_subsections_count(form, empty_case_log, :not_started)).to eq(8)
    end

    it "returns the number of sections in progress" do
      expect(get_subsections_count(form, case_log, :in_progress)).to eq(2)
    end

    it "returns 0 for invalid state" do
      expect(get_subsections_count(form, case_log, :fake)).to eq(0)
    end
  end

  describe "get_first_page_or_check_answers" do
    it "returns the check answers page path if the section has been started already" do
      expect(get_first_page_or_check_answers("household_characteristics", case_log, form)).to match(/check_answers/)
    end

    it "returns the first question page path for the section if it has not been started yet" do
      expect(get_first_page_or_check_answers("household_characteristics", empty_case_log, form)).to match(/tenant_code/)
    end
  end
end
