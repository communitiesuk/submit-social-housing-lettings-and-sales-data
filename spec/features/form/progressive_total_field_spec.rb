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

  it "does not show when js is not enabled" do
    visit("/logs/#{case_log.id}/rent")
    expect(page).to have_selector("#tcharge_div", visible: false)
  end

  it "does show when js is enabled", js: true do
    visit("/logs/#{case_log.id}/rent")
    expect(page).to have_selector("#tcharge_div", visible: true)
  end
end
