require "rails_helper"

RSpec.describe OrganisationsController, type: :request do
  let(:user) { create(:user, :support) }
  let(:headers) { { "Accept" => "text/html" } }
  let(:page) { Capybara::Node::Simple.new(response.body) }

  before do
    allow(user).to receive(:need_two_factor_authentication?).and_return(false)
    sign_in user
  end

  describe "#new" do
    before do
      get new_organisation_path
    end

    it "displays the rent periods question" do
      expect(page).to have_content "What are the rent periods for the organisation?"
    end

    it "the checkboxes for each rent period are checked by default" do
      checkboxes = page.all "input[type='checkbox']"
      expect(checkboxes.count).to be 10
      expect(checkboxes.all? { |box| box[:checked] }).to be true
    end
  end

  describe "#create" do
    let(:org_name) { "abode team" }
    let(:expected_rent_periods) { [1, 2, 3] }
    let(:params) do
      {
        "organisation": {
          name: org_name,
          provider_type: "LA",
          rent_periods: expected_rent_periods,
        },
      }
    end

    before do
      post organisations_path headers:, params:
    end

    it "creates organisation rent periods with the correct rent period and organisation id" do
      org = Organisation.find_by_name org_name
      org_rent_periods = OrganisationRentPeriod.all
      expect(org_rent_periods.count).to be expected_rent_periods.count
      expect(org_rent_periods.map(&:rent_period)).to match_array expected_rent_periods
      expect(org_rent_periods.map(&:organisation_id)).to all be org.id
    end
  end
end
