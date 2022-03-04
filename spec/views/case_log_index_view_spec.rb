require "rails_helper"

RSpec.describe "case_logs/index" do
  let(:in_progress_log) { FactoryBot.create(:case_log, :in_progress) }

  context "with a log list" do
    before do
      assign(:case_logs, [in_progress_log])
      render
    end

    it "renders a table for all logs" do
      expect(rendered).to match(/<table class="govuk-table">/)
      expect(rendered).to match(/logs/)
      expect(rendered).to match(in_progress_log.created_at.to_formatted_s(:govuk_date))
      expect(rendered).to match(in_progress_log.status.humanize)
    end
  end
end
