require "rails_helper"

RSpec.describe Location, type: :model do
  describe "#new" do
    let(:location) { FactoryBot.build(:location) }

    it "belongs to an organisation" do
      expect(location.scheme).to be_a(Scheme)
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

  describe "#units" do
    let(:location) { FactoryBot.build(:location) }

    it "does add an error when the postcode is invalid" do
      location.units = nil
      expect { location.save! }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Units Enter total number of units at this location")
    end
  end

  describe "#type_of_unit" do
    let(:location) { FactoryBot.build(:location) }

    it "does add an error when the postcode is invalid" do
      location.type_of_unit = nil
      expect { location.save! }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Type of unit Select the most common type of unit at this location")
    end
  end
end
