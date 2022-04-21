require "rails_helper"

RSpec.describe Validations::LocalAuthorityValidations do
  subject(:local_auth_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::LocalAuthorityValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "#validate_previous_accommodation_postcode" do
    it "does not add an error if the record ppostcode_full is missing" do
      record.ppostcode_full = nil
      local_auth_validator.validate_previous_accommodation_postcode(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if the record ppostcode_full is valid (uppercase space)" do
      record.previous_postcode_known = 1
      record.ppostcode_full = "M1 1AE"
      local_auth_validator.validate_previous_accommodation_postcode(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if the record ppostcode_full is valid (lowercase no space)" do
      record.previous_postcode_known = 1
      record.ppostcode_full = "m11ae"
      local_auth_validator.validate_previous_accommodation_postcode(record)
      expect(record.errors).to be_empty
    end

    it "does add an error when the postcode is invalid" do
      record.previous_postcode_known = 1
      record.ppostcode_full = "invalid"
      local_auth_validator.validate_previous_accommodation_postcode(record)
      expect(record.errors).not_to be_empty
      expect(record.errors["ppostcode_full"]).to include(match I18n.t("validations.postcode"))
    end
  end

  describe "#validate_la" do
    context "when the rent type is London affordable" do
      let(:expected_error) { I18n.t("validations.property.la.london_rent") }

      it "validates that the local authority is in London" do
        record.la = "E07000105"
        record.rent_type = 2
        local_auth_validator.validate_la(record)
        expect(record.errors["la"]).to include(match(expected_error))
        expect(record.errors["postcode_full"]).to be_empty
      end

      it "expects that the local authority is in London" do
        record.la = "E09000033"
        record.rent_type = 2
        local_auth_validator.validate_la(record)
        expect(record.errors["la"]).to be_empty
      end

      context "when the la has been derived from a known postcode" do
        let(:expected_error) { I18n.t("validations.property.la.london_rent_postcode") }

        it "also adds an error to the postcode field" do
          record.la = "E07000105"
          record.rent_type = 2
          record.postcode_known = 1
          record.postcode_full = "BN18 7TR"
          local_auth_validator.validate_la(record)
          expect(record.errors["postcode_full"]).to include(match(expected_error))
        end
      end
    end

    context "when previous la is known" do
      it "la has to be provided" do
        record.la_known = 1
        local_auth_validator.validate_la(record)
        expect(record.errors["la"])
          .to include(match I18n.t("validations.property.la.la_known"))
      end
    end
  end
end
