require "rails_helper"

RSpec.describe Validations::SetupValidations do
  subject(:setup_validator) { setup_validator_class.new }

  let(:setup_validator_class) { Class.new { include Validations::SetupValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "#validate_irproduct" do
    it "adds an error when the intermediate rent product name is not provided but the rent type was given as other intermediate rent product" do
      record.rent_type = 5
      record.irproduct_other = nil
      setup_validator.validate_irproduct_other(record)
      expect(record.errors["irproduct_other"])
      .to include(match I18n.t("validations.setup.intermediate_rent_product_name.blank"))
    end

    it "adds an error when the intermediate rent product name is blank but the rent type was given as other intermediate rent product" do
      record.rent_type = 5
      record.irproduct_other = ""
      setup_validator.validate_irproduct_other(record)
      expect(record.errors["irproduct_other"])
      .to include(match I18n.t("validations.setup.intermediate_rent_product_name.blank"))
    end

    it "Does not add an error when the intermediate rent product name is provided and the rent type was given as other intermediate rent product" do
      record.rent_type = 5
      record.irproduct_other = "Example"
      setup_validator.validate_irproduct_other(record)
      expect(record.errors["irproduct_other"]).to be_empty
    end
  end

  context "when a user is setting up a supported housing log" do
    describe "#validate_startdate" do
      let(:record) { FactoryBot.create(:case_log, needstype: 2) }
      let(:scheme) { FactoryBot.create(:scheme, end_date: Time.zone.today - 5.days)}
      let(:scheme_no_end_date) { FactoryBot.create(:scheme, end_date: nil)}

      it "validates that the tenancy start date must be today or earlier" do
        record.startdate = Time.zone.today + 3.days
        setup_validator.validate_startdate(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.today_or_earlier"))
      end 

      it "produces no error if the tenancy start date is today or earlier" do
        record.startdate = Time.zone.today
        setup_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end

      it "validates that the tenancy start date is before the end date of the chosen scheme if it has an end date" do
        record.startdate = Time.zone.today - 3.days
        record.scheme = scheme
        setup_validator.validate_startdate(record)
        expect(record.errors["startdate"])
          .to include(match I18n.t("validations.setup.startdate.before_scheme_end_date"))
      end 

      it "produces no error when the tenancy start date is before the end date of the chosen scheme if it has an end date" do
        record.startdate = Time.zone.today - 30.days
        record.scheme = scheme
        setup_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end 

      it "produces no startdate error for scheme end dates when the chosen scheme does not have an end date" do
        record.startdate = Time.zone.today
        record.scheme = scheme_no_end_date
        setup_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end 

      it "validates that tenancy start date is less than 730 days away from the void date" do
        record.startdate = Time.zone.today
        record.voiddate = Time.zone.today - 3.years
        setup_validator.validate_startdate(record)
        expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.voiddate_difference"))
      end

      it "produces no error tenancy start date is less than 730 days away from the void date" do
        record.startdate = Time.zone.today
        record.voiddate = Time.zone.today - 6.months
        setup_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end

      it "validates that tenancy start date is less than 730 days away from the major repairs date" do
        record.startdate = Time.zone.today
        record.mrcdate = Time.zone.today - 3.years
        setup_validator.validate_startdate(record)
        expect(record.errors["startdate"])
        .to include(match I18n.t("validations.setup.startdate.mrcdate_difference"))
      end

      it "produces no error when tenancy start date is less than 730 days away from the major repairs date" do
        record.startdate = Time.zone.today
        record.mrcdate = Time.zone.today - 6.months
        setup_validator.validate_startdate(record)
        expect(record.errors["startdate"]).to be_empty
      end
    end
  end
end
