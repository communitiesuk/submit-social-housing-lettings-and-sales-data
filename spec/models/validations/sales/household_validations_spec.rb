require "rails_helper"

RSpec.describe Validations::Sales::HouseholdValidations do
  subject(:household_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::HouseholdValidations } }

  describe "#validate_number_of_other_people_living_in_the_property" do
    context "when within permitted bounds" do
      let(:record) { FactoryBot.build(:sales_log, hholdcount: 2) }

      it "does not add an error" do
        household_validator.validate_number_of_other_people_living_in_the_property(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when blank" do
      let(:record) { FactoryBot.build(:sales_log, hholdcount: nil) }

      it "does not add an error" do
        household_validator.validate_number_of_other_people_living_in_the_property(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when below lower bound" do
      let(:record) { FactoryBot.build(:sales_log, hholdcount: -1) }

      it "adds an error" do
        household_validator.validate_number_of_other_people_living_in_the_property(record)

        expect(record.errors).to be_present
      end
    end

    context "when higher than upper bound" do
      let(:record) { FactoryBot.build(:sales_log, hholdcount: 5) }

      it "adds an error" do
        household_validator.validate_number_of_other_people_living_in_the_property(record)

        expect(record.errors).to be_present
      end
    end
  end
end
