require "rails_helper"

RSpec.describe "schemes/check_answers.html.erb" do
  let(:organisation) { create(:organisation, holds_own_stock: true) }
  let(:user) { build(:user, organisation:) }
  let(:scheme) { create(:scheme, owning_organisation: user.organisation) }

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
