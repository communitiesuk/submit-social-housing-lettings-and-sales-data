require "rails_helper"
RSpec.describe "Test Features" do
  let!(:case_log){ FactoryBot.create(:case_log) }
  let(:id){ case_log.id }
  let(:status) { case_log.status }

  it "Displays a tasklist header" do
    visit("/case_logs/342351")
    expect(page).to have_content("Tasklist for log 342351")
  end
end
