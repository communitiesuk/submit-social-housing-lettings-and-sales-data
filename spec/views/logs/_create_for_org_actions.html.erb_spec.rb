require "rails_helper"

RSpec.describe "logs/_create_for_org_actions.html.erb" do
  before do
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_page?).and_return(true)
    assign(:organisation, user.organisation)
  end

  let(:fragment) { Capybara::Node::Simple.new(rendered) }

  let(:user) { create(:user) }

  context "with data sharing agreement" do
    it "does include create log buttons" do
      render
      expect(fragment).to have_button("Create a new lettings log")
      expect(fragment).to have_button("Create a new sales log")
    end
  end

  context "without data sharing agreement" do
    let(:user) { create(:user, organisation: create(:organisation, :without_dpc), with_dsa: false) }

    it "does not include create log buttons" do
      render
      expect(fragment).not_to have_button("Create a new lettings log")
      expect(fragment).not_to have_button("Create a new sales log")
    end
  end
end
