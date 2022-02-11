require "rails_helper"

RSpec.describe Validations::DateValidations do
  subject(:date_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::DateValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "tenancy start date" do
    it "cannot be before the first collection window start date" do
      record.startdate = Time.zone.local(2020, 1, 1)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to include(match I18n.t("validations.date.outside_collection_window"))
    end

    it "cannot be after the second collection window end date" do
      record.startdate = Time.zone.local(2023, 7, 1)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to include(match I18n.t("validations.date.outside_collection_window"))
    end

    it "must be a valid date" do
      record.startdate = Time.zone.local(0, 7, 1)
      date_validator.validate_startdate(record)
      expect(record.errors["startdate"]).to include(match I18n.t("validations.date.invalid_date"))
    end
  end
end
