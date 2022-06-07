require "rails_helper"

RSpec.describe ItemLabelHelper do
  let(:item) { "organisation" }

  describe "get the correct label" do
    it "returns singular when count is 1" do
      expect(format_label(1, item)).to eq("organisation")
    end

    it "returns plural when count greater than 1" do
      expect(format_label(2, item)).to eq("organisations")
    end
  end
end
