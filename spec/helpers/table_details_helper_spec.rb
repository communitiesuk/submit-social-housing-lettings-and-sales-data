require "rails_helper"

RSpec.describe DetailsTableHelper do

  describe "details html" do
    subject { details_html(attribute) }

    context "when given a simple attribute" do
      let(:attribute) { { name: "name", value: "Dummy org", editable: true  } }

      it "displays the string wrapped in a div" do
        expect(subject).to eq("<div>Dummy org</div>")
      end
    end

    context "when given a bullet point list of attibutes" do
      let(:list) { ["Camden", "Westminster", "Bristol"] }
      let(:attribute) do
        {
          name: "local_authorities_operated_in",
          value: list,
          editable: false,
          format: :bullet,
        }
      end

      it "displays the string wrapped in an unordered list with the correct classes" do
        expect(subject).to eq("<ul class=\"govuk-list govuk-list--bullet\"><li>Camden</li>\n<br /><li>Westminster</li>\n<br /><li>Bristol</li></ul>")
      end
    end
  end
end
