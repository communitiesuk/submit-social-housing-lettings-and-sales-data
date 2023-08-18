require "rails_helper"

RSpec.describe Validations::LocalAuthorityValidations do
  subject(:local_auth_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::LocalAuthorityValidations } }
  let(:log) { create(:lettings_log) }

  describe "#validate_previous_accommodation_postcode" do
    it "does not add an error if the log ppostcode_full is missing" do
      log.ppostcode_full = nil
      local_auth_validator.validate_previous_accommodation_postcode(log)
      expect(log.errors).to be_empty
    end

    it "does not add an error if the log ppostcode_full is valid (uppercase space)" do
      log.ppcodenk = 0
      log.ppostcode_full = "M1 1AE"
      local_auth_validator.validate_previous_accommodation_postcode(log)
      expect(log.errors).to be_empty
    end

    it "does not add an error if the log ppostcode_full is valid (lowercase no space)" do
      log.ppcodenk = 0
      log.ppostcode_full = "m11ae"
      local_auth_validator.validate_previous_accommodation_postcode(log)
      expect(log.errors).to be_empty
    end

    it "does add an error when the postcode is invalid" do
      log.ppcodenk = 0
      log.ppostcode_full = "invalid"
      local_auth_validator.validate_previous_accommodation_postcode(log)
      expect(log.errors).not_to be_empty
      expect(log.errors["ppostcode_full"]).to include(match I18n.t("validations.postcode"))
    end
  end
end
