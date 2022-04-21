require "rails_helper"

RSpec.describe DocumentListComponent, type: :component do
  let(:items) do
    [{ name: "PDF Form", href: "/forms/form.pdf", description: "An important form", metadata: "4 pages" },
     { name: "Website", href: "https://example.com" }]
  end

  context "when rendering tabs" do
    it "all of the nav tabs specified in the items hash are passed to it" do
      result = render_inline(described_class.new(items:))

      expect(result.text).to include("PDF Form")
      expect(result.text).to include("An important form")
      expect(result.text).to include("4 pages")
      expect(result.text).to include("Website")
    end
  end
end
