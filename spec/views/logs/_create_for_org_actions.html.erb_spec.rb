require "rails_helper"

RSpec.describe "logs/_create_for_org_actions.html.erb" do
  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_page?).and_return(true)
    assign(:organisation, user.organisation)
  end

  let(:fragment) { Capybara::Node::Simple.new(rendered) }

  let(:user) { create(:user) }

  context "when flag disabled" do
    before do
      allow(FeatureToggle).to receive(:new_data_sharing_agreement?).and_return(false)
    end

    it "shows create buttons" do
      render

      expect(fragment).to have_button("Create a new lettings log for this organisation")
      expect(fragment).to have_button("Create a new sales log for this organisation")
    end
  end

  context "when flag enabled" do
    before do
      allow(FeatureToggle).to receive(:new_data_sharing_agreement?).and_return(true)
    end

    context "with data sharing agreement" do
      it "does include create log buttons" do
        render
        expect(fragment).to have_button("Create a new lettings log for this organisation")
        expect(fragment).to have_button("Create a new sales log for this organisation")
      end
    end

    context "without data sharing agreement" do
      let(:user) { create(:user, organisation: create(:organisation, :without_dsa)) }

      it "does not include create log buttons" do
        render
        expect(fragment).not_to have_button("Create a new lettings log for this organisation")
        expect(fragment).not_to have_button("Create a new sales log for this organisation")
      end
    end
  end
end
