require "rails_helper"
require_relative "../../request_helper"

RSpec.describe Validations::PropertyValidations do
  subject(:property_validator) { property_validator_class.new }

  let(:property_validator_class) { Class.new { include Validations::PropertyValidations } }
  let(:record) { FactoryBot.create(:case_log) }
  let(:expected_error) { I18n.t("validations.property.offered.relet_number") }

  describe "#validate_property_number_of_times_relet" do
    it "does not add an error if the record offered is missing" do
      record.offered = nil
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if offered is valid (number between 0 and 20)" do
      record.offered = 0
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
      record.offered = 10
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
      record.offered = 20
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
    end

    it "does add an error when offered is invalid" do
      record.offered = "invalid"
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).not_to be_empty
      expect(record.errors["offered"]).to include(match(expected_error))
      record.offered = 21
      property_validator.validate_property_number_of_times_relet(record)
      expect(record.errors).not_to be_empty
      expect(record.errors["offered"]).to include(match(expected_error))
    end
  end
end
