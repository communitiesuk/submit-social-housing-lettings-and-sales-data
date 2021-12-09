require "rails_helper"
require_relative "../request_helper"

RSpec.describe TasklistHelper do
  before do
    RequestHelper.stub_http_requests
  end
  let(:empty_case_log) { FactoryBot.create(:case_log) }
  let(:case_log) { FactoryBot.create(:case_log, :in_progress) }
  form_handler = FormHandler.instance
  let(:form) { form_handler.get_form("test_form") }

  describe "get next incomplete section" do
    it "returns the first subsection name if it is not completed" do
      expect(get_next_incomplete_section(form, case_log).id).to eq("household_characteristics")
    end

    it "returns the first subsection name if it is partially completed" do
      case_log["tenant_code"] = 123
      expect(get_next_incomplete_section(form, case_log).id).to eq("household_characteristics")
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
      expect(get_subsections_count(form, case_log, :in_progress)).to eq(3)
    end

    it "returns 0 for invalid state" do
      expect(get_subsections_count(form, case_log, :fake)).to eq(0)
    end
  end

  describe "get_first_page_or_check_answers" do
    let(:subsection) { form.get_subsection("household_characteristics") }

    it "returns the check answers page path if the section has been started already" do
      expect(first_page_or_check_answers(subsection, case_log)).to match(/check-answers/)
    end

    it "returns the first question page path for the section if it has not been started yet" do
      expect(first_page_or_check_answers(subsection, empty_case_log)).to match(/tenant-code/)
    end
  end

  describe "subsection link" do
    let(:subsection) { form.get_subsection("household_characteristics") }

    context "for a subsection that's enabled" do
      it "returns the subsection link url" do
        expect(subsection_link(subsection, case_log)).to match(/household-characteristics/)
      end
    end

    context "for a subsection that cannot be started yet" do
      before do
        allow(subsection).to receive(:status).with(case_log).and_return(:cannot_start_yet)
      end

      it "returns a # link" do
        expect(subsection_link(subsection, case_log)).to match(/#/)
      end
    end
  end
end
