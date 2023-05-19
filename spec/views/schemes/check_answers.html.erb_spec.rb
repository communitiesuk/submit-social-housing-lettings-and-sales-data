require "rails_helper"

RSpec.describe "schemes/check_answers.html.erb" do
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
      to_model: Scheme.new,
      check_details_attributes: [],
      check_primary_client_attributes: [
        { name: "Primary client group", value: "foo", id: "primary_client_group" },
      ],
      check_secondary_client_confirmation_attributes: [],
      check_support_attributes: [],
      confirmed?: false,
      errors: ActiveModel::Errors.new(Scheme.new),
    )
  end

  context "when a data provider" do
    it "does not render change links" do
      assign(:scheme, scheme)

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).not_to have_content("Change")
    end

    it "does not render submit button" do
      assign(:scheme, scheme)

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).not_to have_content("Create scheme")
    end
  end
end
