require "rails_helper"
require_relative "../../request_helper"

RSpec.describe CaseLog do
  let(:owning_organisation) { FactoryBot.create(:organisation) }
  let(:managing_organisation) { owning_organisation }

  before do
    RequestHelper.stub_http_requests
  end

  describe "#new" do
    it "raises an error when previous_postcode is present and invalid" do
      expect {
        CaseLog.create!(
          previous_postcode: "invalid_postcode",
          owning_organisation: owning_organisation,
          managing_organisation: managing_organisation,
        )
      }.to raise_error(ActiveRecord::RecordInvalid, /Enter a postcode in the correct format/)
    end
  end
end

RSpec.describe Validations::LocalAuthorityValidations do
  let(:subject) { subject_class.new }
  let(:subject_class) { Class.new { include Validations::LocalAuthorityValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "#validate_previous_accommodation_postcode" do
    it "does not add an error if the record previous_postcode is missing" do
      record.previous_postcode = nil
      subject.validate_previous_accommodation_postcode(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if the record previous_postcode is valid (uppercase space)" do
      record.previous_postcode = "M1 1AE"
      subject.validate_previous_accommodation_postcode(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if the record previous_postcode is valid (lowercase no space)" do
      record.previous_postcode = "m11ae"
      subject.validate_previous_accommodation_postcode(record)
      expect(record.errors).to be_empty
    end

    it "does add an error when the postcode is invalid" do
      record.previous_postcode = "invalid"
      subject.validate_previous_accommodation_postcode(record)
      expect(record.errors).to_not be_empty
      expect(record.errors["previous_postcode"]).to include(match /Enter a postcode in the correct format/)
    end
  end
end
