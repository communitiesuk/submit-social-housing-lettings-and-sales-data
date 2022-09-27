require "rails_helper"

RSpec.describe Validations::SalesValidations do
  subject(:property_validator) { property_validator_class.new }

  let(:property_validator_class) { Class.new { include Validations::SalesValidations } }
  let(:record) { FactoryBot.create(:sales_log) }

  describe "#validate_beds" do
    let(:expected_error) { "Number of bedrooms must be between 1 and 9" }

    it "does not add an error if offered is valid (number between 1 and 9)" do
      record.beds = 9
      property_validator.validate_beds(record)
      expect(record.errors).to be_empty
    end

    it "does add an error if offered is invalid (number not between 1 and 9)" do
      record.beds = 10
      property_validator.validate_beds(record)
      expect(record.errors).eql?(expected_error)
      record.beds = 0
      property_validator.validate_beds(record)
      expect(record.errors).eql?(expected_error)
    end
  end
end