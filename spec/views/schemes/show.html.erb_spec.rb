require "rails_helper"

RSpec.describe "schemes/show.html.erb" do
  let(:organisation) { create(:organisation, holds_own_stock: true) }
  let(:scheme) { create(:scheme, owning_organisation: organisation, confirmed: true) }

  before do
    create(:location, scheme:, confirmed: true)
  end

  context "when data provider" do
    let(:user) { build(:user, organisation:) }

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

  context "when support" do
    let(:user) { build(:user, organisation:, role: "support") }

    it "renders button to deactivate scheme" do
      assign(:scheme, scheme)

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).to have_content("Deactivate this scheme")
    end

    it "does not render button to deactivate scheme if organisation is deactivated" do
      organisation.active = false
      assign(:scheme, scheme)

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).not_to have_content("Deactivate this scheme")
    end
  end
end
