require "rails_helper"

RSpec.describe Validations::SharedValidations do
  subject(:shared_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::SharedValidations } }
  let(:record) { FactoryBot.create(:lettings_log) }
  let(:sales_record) { FactoryBot.create(:sales_log, :completed) }
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

  describe "numeric min max validations" do
    before do
      allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
    end

    context "when validating age" do
      it "validates that person 1's age is a number" do
        record.age1 = "random"
        shared_validator.validate_numeric_min_max(record)
        expect(record.errors["age1"])
          .to include(match I18n.t("validations.numeric.within_range", field: "Lead tenant’s age", min: 16, max: 120))
      end

      it "validates that other household member ages are a number" do
        record.age2 = "random"
        shared_validator.validate_numeric_min_max(record)
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.numeric.within_range", field: "Person 2’s age", min: 1, max: 120))
      end

      it "validates that person 1's age is greater than 16" do
        record.age1 = 15
        shared_validator.validate_numeric_min_max(record)
        expect(record.errors["age1"])
          .to include(match I18n.t("validations.numeric.within_range", field: "Lead tenant’s age", min: 16, max: 120))
      end

      it "validates that other household member ages are greater than 1" do
        record.age2 = 0
        shared_validator.validate_numeric_min_max(record)
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.numeric.within_range", field: "Person 2’s age", min: 1, max: 120))
      end

      it "validates that person 1's age is less than 121" do
        record.age1 = 121
        shared_validator.validate_numeric_min_max(record)
        expect(record.errors["age1"])
          .to include(match I18n.t("validations.numeric.within_range", field: "Lead tenant’s age", min: 16, max: 120))
      end

      it "validates that other household member ages are greater than 121" do
        record.age2 = 123
        shared_validator.validate_numeric_min_max(record)
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.numeric.within_range", field: "Person 2’s age", min: 1, max: 120))
      end

      it "validates that person 1's age is between 16 and 120" do
        record.age1 = 63
        shared_validator.validate_numeric_min_max(record)
        expect(record.errors["age1"]).to be_empty
      end

      it "validates that other household member ages are between 1 and 120" do
        record.age6 = 45
        shared_validator.validate_numeric_min_max(record)
        expect(record.errors["age6"]).to be_empty
      end

      context "with sales log" do
        it "validates that person 2's age is between 0 and 110 for non joint purchase" do
          sales_record.jointpur = 2
          sales_record.hholdcount = 1
          sales_record.details_known_2 = 1
          sales_record.age2 = 130
          shared_validator.validate_numeric_min_max(sales_record)
          expect(sales_record.errors["age2"].first).to eq("Person 2’s age must be between 0 and 110")
        end

        it "validates that buyer 2's age is between 0 and 110 for joint purchase" do
          sales_record.jointpur = 1
          sales_record.age2 = 130
          shared_validator.validate_numeric_min_max(sales_record)
          expect(sales_record.errors["age2"].first).to eq("Buyer 2’s age must be between 0 and 110")
        end
      end
    end

    it "adds the correct validation text when a question has a min but not a max" do
      sales_record.savings = -10
      shared_validator.validate_numeric_min_max(sales_record)
      expect(sales_record.errors["savings"]).to include(match I18n.t("validations.numeric.above_min", field: "Buyer’s total savings (to nearest £10) before any deposit paid", min: "£0"))
    end

    context "when validating percent" do
      it "validates that suffixes are added in the error message" do
        sales_record.ownershipsch = 1
        sales_record.staircase = 1
        sales_record.stairbought = 150
        shared_validator.validate_numeric_min_max(sales_record)
        expect(sales_record.errors["stairbought"])
          .to include(match I18n.t("validations.numeric.within_range", field: "Percentage bought in this staircasing transaction", min: "0%", max: "100%"))
      end
    end

    context "when validating price" do
      it "validates that £ prefix  and , is added in the error message" do
        sales_record.income1 = -5
        shared_validator.validate_numeric_min_max(sales_record)
        expect(sales_record.errors["income1"])
          .to include(match I18n.t("validations.numeric.within_range", field: "Buyer 1’s gross annual income", min: "£0", max: "£999,999"))
      end
    end
  end

  describe "radio options validations" do
    it "allows only possible values" do
      record.needstype = 1
      shared_validator.validate_valid_radio_option(record)

      expect(record.errors["needstype"]).to be_empty
    end

    it "denies impossible values" do
      record.needstype = 3
      shared_validator.validate_valid_radio_option(record)

      expect(record.errors["needstype"]).to be_present
      expect(record.errors["needstype"]).to eql(["Enter a valid value for needs type"])
    end

    context "when feature is toggled off" do
      before do
        allow(FeatureToggle).to receive(:validate_valid_radio_options?).and_return(false)
      end

      it "allows any values" do
        record.needstype = 3
        shared_validator.validate_valid_radio_option(record)

        expect(record.errors["needstype"]).to be_empty
      end
    end
  end
end
