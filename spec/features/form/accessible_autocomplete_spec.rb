require "rails_helper"
require_relative "helpers"
require_relative "../../request_helper"

RSpec.describe "Accessible Automcomplete" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:case_log) do
    FactoryBot.create(
      :case_log,
      :in_progress,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end

  before do
    RequestHelper.stub_http_requests
    sign_in user
  end

  it "allows type ahead filtering", js: true do
    visit("/logs/#{case_log.id}/accessible-select")
    find("#case-log-la-field").click.native.send_keys("T", "h", "a", "n", :down, :enter)
    expect(find("#case-log-la-field").value).to eq("Thanet")
  end
end
