require "rails_helper"

RSpec.describe SearchComponent, type: :component do
  let(:current_user) { FactoryBot.create(:user, :support) }
  let(:label) { "Search by name or email address" }
  let(:page) { Capybara::Node::Simple.new(rendered_component) }
  let(:value) { nil }

  before do
    render_inline(described_class.new(current_user:, label:, value:))
  end

  it "renders a search bar" do
    expect(page).to have_field("search-field", type: "search")
  end

  it "renders the given label" do
    expect(page).to have_content(label)
  end

  context "when a search term has been entered" do
    let(:value) { "search term" }

    it "shows the search term in the input field" do
      expect(page).to have_field("search-field", type: "search", with: value)
    end
  end
end
