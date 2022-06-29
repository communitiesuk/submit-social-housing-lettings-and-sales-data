require "rails_helper"

RSpec.describe SearchComponent, type: :component do
  let(:current_user) { FactoryBot.create(:user, :support) }
  let(:search_label) { "Search by name or email address" }
  let(:value) { nil }

  before do
    allow(request).to receive(:path).and_return("/users")
    render_inline(described_class.new(current_user:, search_label:, value:))
  end

  it "renders a search bar" do
    expect(page).to have_field("search-field", type: "search")
  end

  it "renders the given label" do
    expect(page).to have_content(search_label)
  end

  context "when a search term has been entered" do
    let(:value) { "search term" }

    it "shows the search term in the input field" do
      expect(page).to have_field("search-field", type: "search", with: value)
    end
  end
end
