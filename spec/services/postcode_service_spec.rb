require "rails_helper"

describe PostcodeService do
  let(:postcode) { "SR81LS\u00A0" }

  it "returns clean postcode" do
    expect(described_class.clean(postcode)).to eq "SR81LS"
  end
end
