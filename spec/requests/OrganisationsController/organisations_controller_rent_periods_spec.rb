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
      checkboxes = page.all "input[type='checkbox'][name='organisation[rent_periods][]']"
      expect(checkboxes.count).to be > 5
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
      org = Organisation.includes(:organisation_rent_periods).find_by_name(org_name)
      org_rent_periods = org.organisation_rent_periods
      expect(org_rent_periods.count).to be expected_rent_periods.count
      expect(org_rent_periods.map(&:rent_period)).to match_array expected_rent_periods
      expect(org_rent_periods.map(&:organisation_id)).to all be org.id
    end
  end

  describe "#edit" do
    let(:organisation) { create(:organisation, skip_rent_period_creation: true) }
    let(:fake_rent_periods) do
      {
        "1" => { "value" => "Every minute" },
        "2" => { "value" => "Every decade" },
      }
    end
    let(:checked_rent_period_id) { "1" }

    before do
      allow(RentPeriod).to receive(:rent_period_mappings).and_return fake_rent_periods
      create(:organisation_rent_period, organisation:, rent_period: checked_rent_period_id)
      get edit_organisation_path organisation
    end

    it "displays the rent periods question" do
      expect(page).to have_content "What are the rent periods for the organisation?"
    end

    it "the checkboxes for each rent period are checked where appropriate" do
      checkboxes = page.all "input[type='checkbox']"
      expect(checkboxes.count).to be 2
      expected_checked_checkbox = checkboxes.find { |cb| cb[:value] == checked_rent_period_id }
      expect(expected_checked_checkbox[:checked]).to be true
      expected_not_checked_checkbox = checkboxes.find { |cb| cb[:value] != checked_rent_period_id }
      expect(expected_not_checked_checkbox[:checked]).to be false
    end
  end

  describe "#update" do
    let(:organisation) { create(:organisation, skip_rent_period_creation: true) }
    let(:initially_checked_rent_period_id) { "1" }
    let(:initially_unchecked_rent_period_id) { "2" }
    let(:params) do
      {
        "organisation": {
          name: organisation.name,
          rent_periods: [initially_unchecked_rent_period_id],
          all_rent_periods: [initially_unchecked_rent_period_id, initially_checked_rent_period_id],
        },
      }
    end

    before do
      create(:organisation_rent_period, organisation:, rent_period: initially_checked_rent_period_id)
    end

    it "creates and destroys organisation rent periods as appropriate" do
      rent_periods = Organisation.includes(:organisation_rent_periods)
                                 .find(organisation.id)
                                 .organisation_rent_periods
      expect(rent_periods.count).to be 1
      expect(rent_periods.first.rent_period.to_s).to eq initially_checked_rent_period_id

      patch organisation_path(organisation, headers:, params:)

      rent_periods = Organisation.includes(:organisation_rent_periods)
                                 .find(organisation.id)
                                 .organisation_rent_periods
      expect(rent_periods.count).to be 1
      expect(rent_periods.first.rent_period.to_s).to eq initially_unchecked_rent_period_id
    end
  end
end
