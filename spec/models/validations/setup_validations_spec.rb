require "rails_helper"

RSpec.describe Validations::SetupValidations do
  subject(:setup_validator) { setup_validator_class.new }

  let(:setup_validator_class) { Class.new { include Validations::SetupValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "#validate_intermediate_rent_product_name" do
    it "adds an error when the intermediate rent product name is not provided but the rent type was given as other intermediate rent product" do
      record.rent_type = 5
      record.intermediate_rent_product_name = nil
      setup_validator.validate_intermediate_rent_product_name(record)
      expect(record.errors["intermediate_rent_product_name"])
      .to include(match I18n.t("validations.setup.intermediate_rent_product_name.blank"))
    end

    it "adds an error when the intermediate rent product name is blank but the rent type was given as other intermediate rent product" do
      record.rent_type = 5
      record.intermediate_rent_product_name = ""
      setup_validator.validate_intermediate_rent_product_name(record)
      expect(record.errors["intermediate_rent_product_name"])
      .to include(match I18n.t("validations.setup.intermediate_rent_product_name.blank"))
    end

    it "Does not add an error when the intermediate rent product name is provided and the rent type was given as other intermediate rent product" do
      record.rent_type = 5
      record.intermediate_rent_product_name = "Example"
      setup_validator.validate_intermediate_rent_product_name(record)
      expect(record.errors["intermediate_rent_product_name"]).to be_empty
    end
  end
end
