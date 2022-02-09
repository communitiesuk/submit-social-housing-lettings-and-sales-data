require "rails_helper"

RSpec.describe Validations::LocalAuthorityValidations do
  subject(:local_auth_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::LocalAuthorityValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "#validate_previous_accommodation_postcode" do
    it "does not add an error if the record previous_postcode is missing" do
      record.previous_postcode = nil
      local_auth_validator.validate_previous_accommodation_postcode(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if the record previous_postcode is valid (uppercase space)" do
      record.previous_postcode_known = "Yes"
      record.previous_postcode = "M1 1AE"
      local_auth_validator.validate_previous_accommodation_postcode(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if the record previous_postcode is valid (lowercase no space)" do
      record.previous_postcode_known = "Yes"
      record.previous_postcode = "m11ae"
      local_auth_validator.validate_previous_accommodation_postcode(record)
      expect(record.errors).to be_empty
    end

    it "does add an error when the postcode is invalid" do
      record.previous_postcode_known = "Yes"
      record.previous_postcode = "invalid"
      local_auth_validator.validate_previous_accommodation_postcode(record)
      expect(record.errors).not_to be_empty
      expect(record.errors["previous_postcode"]).to include(match I18n.t("validations.postcode"))
    end
  end
end
