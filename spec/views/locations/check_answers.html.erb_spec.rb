require "rails_helper"

RSpec.describe "locations/check_answers.html.erb" do
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
      )
    end

    let(:location) do
      instance_double(
        Location,
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
        startdate: 1.day.ago,
        is_la_inferred: nil,
      )
    end

    it "does not see create submission button" do
      assign(:scheme, scheme)
      assign(:location, location)

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).not_to have_content("Save and return to locations")
    end

    it "does not see change answer links" do
      assign(:scheme, scheme)
      assign(:location, location)

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).not_to have_content("Change")
    end
  end
end
