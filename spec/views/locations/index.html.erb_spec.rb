require "rails_helper"

RSpec.describe "locations/index.html.erb" do
  context "when a data provider" do
    let(:user) { create(:user) }

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
        locations: Location,
      )
    end

    it "does not see add a location button" do
      assign(:pagy, Pagy.new(count: 0, page: 1))
      assign(:scheme, scheme)
      assign(:locations, [])

      allow(view).to receive(:current_user).and_return(user)
      allow(SearchComponent).to receive(:new).and_return(inline: "")

      render

      expect(rendered).not_to have_content("Add a location")
    end
  end
end
