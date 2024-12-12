require "rails_helper"

RSpec.describe SearchResultCaptionComponent, type: :component do
  let(:searched) { "search item" }
  let(:count) { 2 }
  let(:item_label) { "user" }
  let(:total_count) { 3 }
  let(:item) { "scheme" }
  let(:filters_count) { 1 }
  let(:result) { render_inline(described_class.new(searched:, count:, item_label:, total_count:, item:, filters_count:)) }

  context "when search and filter results are found" do
    it "renders table caption including the search results and total" do
      expect(result.to_html).to eq("<span>\n    <strong>2</strong> users matching search and filters<br>\n</span>\n")
    end
  end

  context "when search results are found" do
    let(:filters_count) { nil }

    it "renders table caption including the search results and total" do
      expect(result.to_html).to eq("<span>\n    <strong>2</strong> users matching search<br>\n</span>\n")
    end

    context "with 1 result" do
      let(:count) { 1 }

      it "renders table caption including the search results and total" do
        expect(result.to_html).to eq("<span>\n    <strong>1</strong> user matching search<br>\n</span>\n")
      end
    end
  end

  context "when filter results are found" do
    let(:searched) { nil }

    it "renders table caption including the search results and total" do
      expect(result.to_html).to eq("<span>\n    <strong>2</strong> users matching filters<br>\n</span>\n")
    end

    context "with 1 result" do
      let(:count) { 1 }

      it "renders table caption including the search results and total" do
        expect(result.to_html).to eq("<span>\n    <strong>1</strong> user matching filters<br>\n</span>\n")
      end
    end
  end

  context "when no search/filter is applied" do
    let(:searched) { nil }
    let(:filters_count) { nil }

    it "renders table caption with total count only" do
      expect(result.to_html).to eq("<span>\n    <span class=\"govuk-!-margin-right-4\">\n      <strong>2</strong> total schemes\n    </span>\n</span>\n")
    end

    context "with 1 result" do
      let(:count) { 1 }

      it "renders table caption with total count only" do
        expect(result.to_html).to eq("<span>\n    <span class=\"govuk-!-margin-right-4\">\n      <strong>1</strong> total scheme\n    </span>\n</span>\n")
      end
    end
  end

  context "when nothing is found" do
    let(:count) { 0 }

    it "renders table caption with total count only" do
      expect(result.to_html).to eq("<span>\n    <strong>0</strong> users matching search and filters<br>\n</span>\n")
    end
  end

  context "when 1 record is found" do
    let(:count) { 1 }

    it "renders table caption with total count only" do
      expect(result.to_html).to eq("<span>\n    <strong>1</strong> user matching search and filters<br>\n</span>\n")
    end
  end
end
