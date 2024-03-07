require "rails_helper"

RSpec.describe "locations/show.html.erb" do
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

  let(:location) do
    instance_double(
      Location,
      id: 5,
      name: "some location",
      postcode: "EC1N 2TD",
      linked_local_authorities: [],
      units: "",
      type_of_unit: "",
      mobility_type: "",
      available_from: 1.week.ago,
      location_deactivation_periods: [],
      status: :active,
      active?: true,
      scheme:,
      deactivates_in_a_long_time?: false,
      is_la_inferred: nil,
    )
  end

  context "when a data provider" do
    let(:user) { create(:user) }

    it "does not see add a location button" do
      assign(:scheme, scheme)
      assign(:location, location)

      allow(view).to receive(:current_user).and_return(user)
      allow(location).to receive(:deactivated?).and_return(false)

      render

      expect(rendered).not_to have_content("Deactivate this location")
    end

    it "does not see change answer links" do
      assign(:scheme, scheme)
      assign(:location, location)

      allow(view).to receive(:current_user).and_return(user)
      allow(location).to receive(:deactivated?).and_return(false)

      render

      expect(rendered).not_to have_content("Change")
    end
  end

  context "when a support user" do
    let(:user) { create(:user, role: "support") }

    it "sees deactivate scheme location button" do
      assign(:scheme, scheme)
      assign(:location, location)

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).to have_content("Deactivate this location")
    end

    it "does not see deactivate scheme location button when organisation is deactivated" do
      user.organisation.active = false

      assign(:scheme, scheme)
      assign(:location, location)

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).not_to have_content("Deactivate this location")
    end
  end
end
