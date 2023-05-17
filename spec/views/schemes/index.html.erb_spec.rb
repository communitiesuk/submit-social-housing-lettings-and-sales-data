require "rails_helper"

RSpec.describe "schemes/index.html.erb" do
  context "when data provider" do
    let(:user) { build(:user) }

    it "does not render button to create schemes" do
      assign(:pagy, Pagy.new(count: 0, page: 1))
      assign(:schemes, [])

      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).not_to have_content("Create a new supported housing scheme")
    end
  end
end
