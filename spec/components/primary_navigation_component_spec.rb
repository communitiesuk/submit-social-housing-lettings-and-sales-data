require "rails_helper"

RSpec.describe PrimaryNavigationComponent, type: :component do
  let(:items) do
    [{ name: "Organisations", url: "#", current: true },
     { name: "Users", url: "#" },
     { name: "Logs ", url: "#" }]
  end

  context "when the item is 'current' in nav tabs" do
    it "then that tab appears as selected" do
      result = render_inline(described_class.new(items:))

      expect(result.css('.app-primary-navigation__link[aria-current="page"]').text).to include("Organisations")
    end
  end

  context "when rendering tabs" do
    it "all of the nav tabs specified in the items hash are passed to it" do
      result = render_inline(described_class.new(items:))

      expect(result.text).to include("Organisations")
      expect(result.text).to include("Users")
      expect(result.text).to include("Logs")
    end
  end
end
