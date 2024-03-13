require "rails_helper"

describe AddressDataPresenter do
  let(:data) do
    JSON.parse(
      '{
        "UPRN": "UPRN",
        "UDPRN": "UDPRN",
        "ADDRESS": "full address",
        "SUB_BUILDING_NAME": "0",
        "BUILDING_NAME": "building name",
        "THOROUGHFARE_NAME": "thoroughfare",
        "POST_TOWN": "posttown",
        "POSTCODE": "postcode",
        "STATUS": "APPROVED",
        "DOUBLE_DEPENDENT_LOCALITY": "double dependent locality",
        "DEPENDENT_LOCALITY": "dependent locality",
        "CLASSIFICATION_CODE": "classification code",
        "LOCAL_CUSTODIAN_CODE_DESCRIPTION": "LONDON BOROUGH OF HARINGEY",
        "BLPU_STATE_CODE": "2",
        "BLPU_STATE_CODE_DESCRIPTION": "In use",
        "LAST_UPDATE_DATE": "31/07/2020",
        "ENTRY_DATE": "30/01/2015",
        "BLPU_STATE_DATE": "30/01/2015",
        "LANGUAGE": "EN",
        "MATCH_DESCRIPTION": "EXACT",
        "MATCH": "1.0"
      }',
    )
  end

  let(:presenter) { described_class.new(data) }

  describe "#uprn" do
    it "returns uprn" do
      expect(presenter.uprn).to eq("UPRN")
    end
  end

  describe "#match" do
    it "returns match" do
      expect(presenter.match).to eq("1.0")
    end
  end

  describe "#address" do
    it "returns address" do
      expect(presenter.address).to eq("full address")
    end
  end
end
