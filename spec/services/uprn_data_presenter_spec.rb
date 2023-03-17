require "rails_helper"

describe UprnDataPresenter do
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
        "MATCH_DESCRIPTION": "EXACT"
      }',
    )
  end

  let(:presenter) { described_class.new(data) }

  describe "#postcode" do
    it "returns postcode" do
      expect(presenter.postcode).to eq("postcode")
    end
  end

  describe "#address_line1" do
    it "returns address_line1" do
      expect(presenter.address_line1).to eq("0, Building Name, Thoroughfare")
    end
  end

  describe "#address_line2" do
    it "returns address_line2" do
      expect(presenter.address_line2).to eq("Double Dependent Locality, Dependent Locality")
    end
  end

  describe "#town_or_city" do
    it "returns town_or_city" do
      expect(presenter.town_or_city).to eq("Posttown")
    end
  end

  context "when address_line2 fields are missing" do
    let(:data) { {} }

    describe "#address_line2" do
      it "returns nil" do
        expect(presenter.address_line2).to be_nil
      end
    end
  end
end
