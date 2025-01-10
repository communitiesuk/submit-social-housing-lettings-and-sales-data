require "rails_helper"

RSpec.describe Validations::SharedValidations do
  subject(:shared_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::SharedValidations } }
  let(:lettings_log) { create(:lettings_log) }
  let(:sales_log) { create(:sales_log, :completed) }
  let(:fake_2021_2022_form) { Form.new("spec/fixtures/forms/2021_2022.json") }

  describe "numeric min max validations" do
    before do
      allow(FormHandler.instance).to receive(:current_lettings_form).and_return(fake_2021_2022_form)
    end

    context "when validating age" do
      it "validates that person 1's age is a number" do
        lettings_log.age1 = "random"
        shared_validator.validate_numeric_min_max(lettings_log)
        expect(lettings_log.errors["age1"])
          .to include(match I18n.t("validations.shared.numeric.within_range", field: "Lead tenant’s age", min: 16, max: 120))
      end

      it "validates that other household member ages are a number" do
        lettings_log.age2 = "random"
        shared_validator.validate_numeric_min_max(lettings_log)
        expect(lettings_log.errors["age2"])
          .to include(match I18n.t("validations.shared.numeric.within_range", field: "Person 2’s age", min: 1, max: 120))
      end

      it "validates that person 1's age is greater than 16" do
        lettings_log.age1 = 15
        shared_validator.validate_numeric_min_max(lettings_log)
        expect(lettings_log.errors["age1"])
          .to include(match I18n.t("validations.shared.numeric.within_range", field: "Lead tenant’s age", min: 16, max: 120))
      end

      it "validates that other household member ages are greater than 1" do
        lettings_log.age2 = 0
        shared_validator.validate_numeric_min_max(lettings_log)
        expect(lettings_log.errors["age2"])
          .to include(match I18n.t("validations.shared.numeric.within_range", field: "Person 2’s age", min: 1, max: 120))
      end

      it "validates that person 1's age is less than 121" do
        lettings_log.age1 = 121
        shared_validator.validate_numeric_min_max(lettings_log)
        expect(lettings_log.errors["age1"])
          .to include(match I18n.t("validations.shared.numeric.within_range", field: "Lead tenant’s age", min: 16, max: 120))
      end

      it "validates that other household member ages are greater than 121" do
        lettings_log.age2 = 123
        shared_validator.validate_numeric_min_max(lettings_log)
        expect(lettings_log.errors["age2"])
          .to include(match I18n.t("validations.shared.numeric.within_range", field: "Person 2’s age", min: 1, max: 120))
      end

      it "validates that person 1's age is between 16 and 120" do
        lettings_log.age1 = 63
        shared_validator.validate_numeric_min_max(lettings_log)
        expect(lettings_log.errors["age1"]).to be_empty
      end

      it "validates that other household member ages are between 1 and 120" do
        lettings_log.age6 = 45
        shared_validator.validate_numeric_min_max(lettings_log)
        expect(lettings_log.errors["age6"]).to be_empty
      end

      context "with sales log" do
        it "validates that person 2's age is between 0 and 110 for non joint purchase" do
          sales_log.jointpur = 2
          sales_log.hholdcount = 1
          sales_log.details_known_2 = 1
          sales_log.age2 = 130
          shared_validator.validate_numeric_min_max(sales_log)
          expect(sales_log.errors["age2"].first).to eq("Person 2’s age must be between 0 and 110.")
        end

        it "validates that buyer 2's age is between 0 and 110 for joint purchase" do
          sales_log.jointpur = 1
          sales_log.age2 = 130
          shared_validator.validate_numeric_min_max(sales_log)
          expect(sales_log.errors["age2"].first).to eq("Buyer 2’s age must be between 16 and 110.")
        end
      end
    end

    it "adds the correct validation text when a question has a min but not a max" do
      sales_log.savings = -10
      sales_log.jointpur = 1
      shared_validator.validate_numeric_min_max(sales_log)
      expect(sales_log.errors["savings"]).to include(match I18n.t("validations.shared.numeric.above_min", field: "Buyers’ total savings before any deposit paid", min: "£0"))
    end

    context "when validating percent" do
      it "validates that suffixes are added in the error message" do
        sales_log.ownershipsch = 1
        sales_log.staircase = 1
        sales_log.stairbought = 150
        shared_validator.validate_numeric_min_max(sales_log)
        expect(sales_log.errors["stairbought"])
          .to include(match I18n.t("validations.shared.numeric.within_range", field: "Percentage bought in this staircasing transaction", min: "0%", max: "100%"))
      end
    end

    context "when validating price" do
      it "validates that prefix £ and delimeter ',' is added in the error message" do
        sales_log.income1 = -5
        shared_validator.validate_numeric_min_max(sales_log)
        expect(sales_log.errors["income1"])
          .to include(match I18n.t("validations.shared.numeric.within_range", field: "Buyer 1’s gross annual income", min: "£0", max: "£999,999"))
      end
    end
  end

  describe "validating level of accuracy or rounding for numeric questions" do
    let(:sales_log) { build(:sales_log, :completed) }

    before do
      income_question = instance_double(Form::Question, step:, type: "numeric", id: "income1", check_answer_label: "Buyer 1’s gross annual income", page: instance_double(Form::Page, routed_to?: true))
      form = instance_double(Form, numeric_questions: [income_question])
      allow(FormHandler.instance).to receive(:get_form).and_return(form)
    end

    context "when validating a question with a step of 1" do
      let(:step) { 1 }

      it "adds an error if input is a decimal" do
        sales_log.income1 = 30_000.5
        shared_validator.validate_numeric_step(sales_log)
        expect(sales_log.errors[:income1]).to include I18n.t("validations.shared.numeric.whole_number", field: "Buyer 1’s gross annual income")
      end

      it "does not add an error if input is an integer" do
        sales_log.income1 = 30_000
        shared_validator.validate_numeric_step(sales_log)
        expect(sales_log.errors).to be_empty
      end
    end

    context "when validating a question with a step of 10" do
      let(:step) { 10 }

      it "adds an error if input is not a multiple of ten" do
        sales_log.income1 = 30_005
        shared_validator.validate_numeric_step(sales_log)
        expect(sales_log.errors[:income1]).to include I18n.t("validations.shared.numeric.nearest_ten", field: "Buyer 1’s gross annual income")
      end

      it "does not add an error if input is a multiple of ten" do
        sales_log.income1 = 30_000
        shared_validator.validate_numeric_step(sales_log)
        expect(sales_log.errors).to be_empty
      end
    end

    context "when validating a question with a step of 0.01" do
      let(:step) { 0.01 }

      it "adds an error if input has more than 2 decimal places" do
        sales_log.income1 = 30_123.7418
        shared_validator.validate_numeric_step(sales_log)
        expect(sales_log.errors[:income1]).to include I18n.t("validations.shared.numeric.nearest_hundredth", field: "Buyer 1’s gross annual income")
      end

      it "does not add an error if input has 2 or fewer decimal places" do
        sales_log.income1 = 30_123.74
        shared_validator.validate_numeric_step(sales_log)
        expect(sales_log.errors).to be_empty
      end
    end

    context "when validating a question with a step of 0.1" do
      let(:step) { 0.1 }

      it "adds an error if input has more than 1 decimal place" do
        sales_log.income1 = 30_123.74
        shared_validator.validate_numeric_step(sales_log)
        expect(sales_log.errors[:income1]).to include I18n.t("validations.shared.numeric.nearest_tenth", field: "Buyer 1’s gross annual income")
      end

      it "does not add an error if input has 1 or fewer decimal places" do
        sales_log.income1 = 30_123.8
        shared_validator.validate_numeric_step(sales_log)
        expect(sales_log.errors).to be_empty
      end
    end

    context "when validating a question with an unusual step" do
      let(:step) { 0.001 }

      it "adds an appropriate error if input does not match" do
        sales_log.income1 = 30_123.7419
        shared_validator.validate_numeric_step(sales_log)
        expect(sales_log.errors[:income1]).to include I18n.t("validations.shared.numeric.nearest_step", field: "Buyer 1’s gross annual income", step: 0.001)
      end
    end
  end

  %i[sales_log lettings_log].each do |log_type|
    describe "validate_owning_organisation_data_sharing_agremeent_signed" do
      it "is valid if the Data Protection Confirmation is signed" do
        log = build(log_type, :in_progress, owning_organisation: create(:organisation))

        expect(log).to be_valid
      end

      it "is valid when owning_organisation nil" do
        log = build(log_type, owning_organisation: nil)

        expect(log).to be_valid
      end

      it "is not valid if the Data Protection Confirmation is not signed" do
        log = build(log_type, owning_organisation: create(:organisation, :without_dpc))

        expect(log).not_to be_valid
        expect(log.errors[:owning_organisation_id]).to eq(["The organisation must accept the Data Sharing Agreement before it can be selected as the owning organisation."])
      end

      context "when updating" do
        let(:log) { create(log_type, :in_progress) }
        let(:org_with_dpc) { create(:organisation) }
        let(:org_without_dpc) { create(:organisation, :without_dpc) }

        it "is valid when changing to another org with a signed Data Protection Confirmation" do
          expect { log.owning_organisation = org_with_dpc }.not_to change(log, :valid?)
        end

        it "invalid when changing to another org without a signed Data Protection Confirmation" do
          expect { log.owning_organisation = org_without_dpc }.to change(log, :valid?).from(true).to(false).and(change { log.errors[:owning_organisation_id] }.to(["The organisation must accept the Data Sharing Agreement before it can be selected as the owning organisation."]))
        end
      end
    end
  end

  describe "validate numeric question input" do
    it "does not allow letters" do
      sales_log.income1 = "abc"
      shared_validator.validate_numeric_input(sales_log)
      expect(sales_log.errors[:income1]).to include I18n.t("validations.shared.numeric.format", field: "Buyer 1’s gross annual income")
    end

    it "does not allow special characters" do
      sales_log.income1 = "3%5"
      shared_validator.validate_numeric_input(sales_log)
      expect(sales_log.errors[:income1]).to include I18n.t("validations.shared.numeric.format", field: "Buyer 1’s gross annual income")
    end

    it "does not allow exponent format" do
      sales_log.income1 = "1e4"
      shared_validator.validate_numeric_input(sales_log)
      expect(sales_log.errors[:income1]).to include I18n.t("validations.shared.numeric.format", field: "Buyer 1’s gross annual income")
    end

    it "allows a digit" do
      sales_log.income1 = "300"
      shared_validator.validate_numeric_input(sales_log)
      expect(sales_log.errors[:income1]).to be_empty
    end

    it "allows a decimal point" do
      sales_log.income1 = "300.78"
      shared_validator.validate_numeric_input(sales_log)
      expect(sales_log.errors[:income1]).to be_empty
    end

    it "does not allow decimal point in a wrong format" do
      sales_log.income1 = "300.09.78"
      shared_validator.validate_numeric_input(sales_log)
      expect(sales_log.errors[:income1]).to include I18n.t("validations.shared.numeric.format", field: "Buyer 1’s gross annual income")
    end
  end
end
