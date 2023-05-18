require "rails_helper"

RSpec.describe "schemes/show.html.erb" do
  before do
    allow(FeatureToggle).to receive(:scheme_toggle_enabled?).and_return(true)
  end

  context "when data provider" do
    let(:user) { build(:user) }

    let(:scheme) do
      instance_double(
        Scheme,
        owning_organisation: user.organisation,
        id: 1,
        service_name: "some name",
        id_to_display: "S1",
        sensitive: false,
        scheme_type: "some type",
        registered_under_care_act: false,
        arrangement_type: "some other type",
        primary_client_group: false,
        has_other_client_group: false,
        secondary_client_group: false,
        support_type: "some support type",
        intended_stay: "some intended stay",
        available_from: 1.week.ago,
        scheme_deactivation_periods: [],
        status: :active,
      )
    end

    it "does not render button to deactivate schemes" do
      assign(:scheme, scheme)

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).not_to have_content("Deactivate this scheme")
    end

    it "does not see change answer links" do
      assign(:scheme, scheme)

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).not_to have_content("Change")
    end
  end
end
