require "rails_helper"

RSpec.describe DetailsTableHelper do
  describe "details html" do
    let(:details) { details_html(attribute) }

    context "when given a simple attribute" do
      let(:attribute) { { name: "name", value: "Dummy org", editable: true } }

      it "displays the string wrapped in a p" do
        expect(details).to eq("<p class=\"govuk-body\">Dummy org</p>")
      end
    end

    context "when given a bullet point list of attibutes" do
      let(:list) { %w[Camden Westminster Bristol] }
      let(:attribute) do
        {
          name: "local_authorities_operated_in",
          value: list,
          editable: false,
          format: :bullet,
        }
      end

      it "displays the string wrapped in an unordered list with the correct classes" do
        expect(details).to eq("<ul class=\"govuk-list govuk-list--bullet\"><li>Camden</li><li>Westminster</li><li>Bristol</li></ul>")
      end
    end

    context "when given a bullet point list with one attibute" do
      let(:list) { %w[Camden] }
      let(:attribute) do
        {
          name: "local_authorities_operated_in",
          value: list,
          editable: false,
          format: :bullet,
        }
      end

      it "displays the string wrapped in a p" do
        expect(details).to eq("<p class=\"govuk-body\">Camden</p>")
      end
    end
  end
end
