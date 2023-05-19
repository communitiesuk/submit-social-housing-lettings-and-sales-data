require "rails_helper"

RSpec.describe "schemes/show.html.erb" do
  context "when data provider" do
    let(:organisation) { create(:organisation, holds_own_stock: true) }
    let(:user) { build(:user, organisation:) }
    let(:scheme) { create(:scheme, owning_organisation: user.organisation) }

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
