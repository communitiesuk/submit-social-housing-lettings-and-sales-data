require "rails_helper"

RSpec.describe "schemes/deactivate_confirm.html.erb", type: :view do
  let(:scheme) { create(:scheme, service_name: "ABCScheme") }
  let(:deactivation_date) { Time.zone.today + 1.month }
  let(:affected_logs) { create_list(:lettings_log, 2, scheme:, status: 1) }
  let(:affected_locations) { create_list(:location, 3, scheme:) }
  let(:scheme_deactivation_period) { SchemeDeactivationPeriod.new }

  before do
    assign(:scheme, scheme)
    assign(:deactivation_date, deactivation_date)
    assign(:affected_logs, affected_logs)
    assign(:affected_locations, affected_locations)
    assign(:scheme_deactivation_period, scheme_deactivation_period)
    render
  end

  it "displays the service name in the caption" do
    expect(rendered).to have_css("span.govuk-caption-l", text: scheme.service_name)
  end

  it "displays the correct heading" do
    expect(rendered).to have_css("h1.govuk-heading-l", text: "This change will affect 2 logs and 3 locations.")
  end

  it "displays the affected logs count" do
    expect(rendered).to have_text("2 existing logs using this scheme have a tenancy start date after #{deactivation_date.to_formatted_s(:govuk_date)}.")
  end

  it "displays the warning text" do
    expect(rendered).to have_css(".govuk-warning-text", text: I18n.t("warnings.scheme.deactivate.review_logs"))
  end

  it "displays the affected locations count" do
    expect(rendered).to have_text("This scheme has 3 locations active on #{deactivation_date.to_formatted_s(:govuk_date)}.")
  end

  it "renders the submit button" do
    expect(rendered).to have_button("Deactivate this scheme")
  end

  it "renders the cancel button" do
    expect(rendered).to have_link("Cancel", href: scheme_details_path(scheme))
  end
end
