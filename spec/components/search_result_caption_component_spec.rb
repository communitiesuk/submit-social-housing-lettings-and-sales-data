require "rails_helper"

RSpec.describe SearchResultCaptionComponent, type: :component do
  let(:page) { Capybara::Node::Simple.new(rendered_component) }
  let(:searched) { "search item" }
  let(:count) { 2 }
  let(:item_label) { "user" }
  let(:total_count) { 3 }
  let(:item) { "schemes" }
  let(:path) { "path" }

  it "all of the nav tabs specified in the items hash are passed to it" do
    result = render_inline(described_class.new(searched:, count:, item_label:, total_count:, item:, path:))
    expect(result.to_html).to eq("  <span class=\"govuk-!-margin-right-4\">\n      <strong>#{count}</strong> #{item_label} found matching ‘#{searched}’ of <strong>#{total_count}</strong> total #{item}. <a class=\"govuk-link\" href=\"path\">Clear search</a>\n</span>\n")
  end

  context "when no search results are found" do
    let(:searched) { nil }

    it "all of the nav tabs specified in the items hash are passed to it" do
      result = render_inline(described_class.new(searched:, count:, item_label:, total_count:, item:, path:))

      expect(result.to_html).to eq("  <span class=\"govuk-!-margin-right-4\">\n      <strong>#{count}</strong> total #{item}.\n</span>\n")
    end
  end
end
