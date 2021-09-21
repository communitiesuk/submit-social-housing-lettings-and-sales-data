require "rails_helper"
RSpec.describe "case_logs/index" do
  let(:in_progress_log) { FactoryBot.build(:case_log, :in_progress) }
  let(:submitted_log) { FactoryBot.build(:case_log, :submitted) }

  context 'given an in progress log list' do
    it 'renders a table for in progress logs only' do
      assign(:in_progress_case_logs, [in_progress_log])
      assign(:submitted_case_logs, [])
      render
      expect(rendered).to match(/<table class="govuk-table">/)
      expect(rendered).to match(/Logs you need to complete/)
      expect(rendered).not_to match(/Logs you&#39;ve submitted/)
      expect(rendered).to match(in_progress_log.tenant_code)
      expect(rendered).to match(in_progress_log.postcode)
    end
  end

  context 'given a submitted log list' do
    it 'renders a table for in progress logs only' do
      assign(:in_progress_case_logs, [])
      assign(:submitted_case_logs, [submitted_log])
      render
      expect(rendered).to match(/<table class="govuk-table">/)
      expect(rendered).to match(/Logs you&#39;ve submitted/)
      expect(rendered).not_to match(/Logs you need to complete/)
      expect(rendered).to match(submitted_log.tenant_code)
      expect(rendered).to match(submitted_log.postcode)
    end
  end

  context 'given a submitted log list and an in_progress log list' do
    it 'renders two tables, one for each status' do
      assign(:in_progress_case_logs, [in_progress_log])
      assign(:submitted_case_logs, [submitted_log])
      render
      expect(rendered).to match(/<table class="govuk-table">/)
      expect(rendered).to match(/Logs you&#39;ve submitted/)
      expect(rendered).to match(/Logs you need to complete/)
    end
  end
end
