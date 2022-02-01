require "rails_helper"

RSpec.describe TabNavigationComponent, type: :component do
  let(:items) do
    [{ name: "Application", url: "#", current: true },
     { name: "Notes", url: "#" },
     { name: "Timeline", url: "#" }]
  end

  context "when the item is 'current' in nav tabs" do
    it "then that tab appears as selected" do
      result = render_inline(described_class.new(items: items))

      expect(result.css('.app-tab-navigation__link[aria-current="page"]').text).to include("Application")
    end
  end

  context "when rendering tabs" do
    it "all of the nav tabs specified in the items hash are passed to it" do
      result = render_inline(described_class.new(items: items))

      expect(result.text).to include("Application")
      expect(result.text).to include("Notes")
      expect(result.text).to include("Timeline")
    end
  end
end
