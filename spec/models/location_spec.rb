require "rails_helper"

RSpec.describe Location, type: :model do
  describe "#new" do
    let(:location) { FactoryBot.build(:location) }

    before do
      stub_request(:get, /api.postcodes.io/)
        .to_return(status: 200, body: "{\"status\":200,\"result\":{\"admin_district\":\"Manchester\",\"codes\":{\"admin_district\": \"E08000003\"}}}", headers: {})
    end

    it "belongs to an organisation" do
      expect(location.scheme).to be_a(Scheme)
    end

    it "infers the local authority" do
      location.postcode = "M1 1AE"
      location.save!
      expect(location.location_code).to eq("E08000003")
    end
  end

  describe "#validate_postcode" do
    let(:location) { FactoryBot.build(:location) }

    it "does not add an error if postcode is valid" do
      location.postcode = "M1 1AE"
      location.save!
      expect(location.errors).to be_empty
    end

    it "does add an error when the postcode is invalid" do
      location.postcode = "invalid"
      expect { location.save! }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Postcode Enter a postcode in the correct format, for example AA1 1AA")
    end
  end
end
