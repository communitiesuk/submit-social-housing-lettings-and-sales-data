require "rails_helper"

describe PostcodeService do
  let(:postcode) { "s r81LS\u00A0" }

  it "returns clean postcode" do
    expect(described_class.clean(postcode)).to eq "SR81LS"
  end

  describe "#lookup" do
    context "with valid postcode" do
      subject(:result) { described_class.new.lookup("AA11AA") }

      it "returns hash" do
        expect(result[:location_code]).to eq("E09000033")
        expect(result[:location_admin_district]).to eq("Westminster")
        expect(result[:outcode]).to eq("AA1")
        expect(result[:incode]).to eq("1AA")
        expect(result[:result?]).to be true
      end

      it "returns object" do
        expect(result.location_code).to eq("E09000033")
        expect(result.location_admin_district).to eq("Westminster")
        expect(result.outcode).to eq("AA1")
        expect(result.incode).to eq("1AA")
        expect(result.result?).to be true
      end
    end
  end
end
