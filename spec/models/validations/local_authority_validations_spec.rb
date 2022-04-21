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
      it "expects that the local authority is in London" do
        record.la = "E09000033"
        record.rent_type = 2
        local_auth_validator.validate_la(record)
        expect(record.errors["la"]).to be_empty
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

    context "when the organisation only operates in specific local authorities" do
      let(:organisation) { FactoryBot.create(:organisation) }
      let(:record) { FactoryBot.create(:case_log, owning_organisation: organisation) }

      before do
        FactoryBot.create(:organisation_la, organisation:, ons_code: "E07000178")
        FactoryBot.create(:organisation_la, organisation:, ons_code: "E09000033")
      end

      it "validates that the local authority is one the owning organisation operates in" do
        record.la = "E06000014"
        local_auth_validator.validate_la(record)
        expect(record.errors["la"])
          .to include(match I18n.t(
            "validations.property.la.la_invalid_for_org",
            org_name: organisation.name,
            la_name: "York",
          ))
      end

      it "expects that the local authority can be one that the owning organisation operates in" do
        record.la = "E07000178"
        local_auth_validator.validate_la(record)
        expect(record.errors["la"]).to be_empty
      end
    end

    context "when the organisation has not listed specific local authorities it operates in" do
      it "does not validate the local authority for the organisation" do
        record.la = "E06000014"
        local_auth_validator.validate_la(record)
        expect(record.errors["la"]).to be_empty
      end
    end
  end
end
