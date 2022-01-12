require "rails_helper"
require_relative "../../request_helper"

RSpec.describe CaseLog do
  let(:owning_organisation) { FactoryBot.create(:organisation) }
  let(:managing_organisation) { owning_organisation }

  before do
    RequestHelper.stub_http_requests
  end

  describe "#new" do
    it "raises an error when offered is present and invalid" do
      expect {
        CaseLog.create!(
          offered: "random",
          owning_organisation: owning_organisation,
          managing_organisation: managing_organisation,
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end

RSpec.describe Validations::PropertyValidations do
  let(:subject) { subject_class.new }
  let(:subject_class) { Class.new { include Validations::PropertyValidations } }
  let(:record) { FactoryBot.create(:case_log) }
  let(:expected_error) { "Number of times property has been offered for relet must be a number between 0 and 20" }

  describe "#validate_property_number_of_times_relet" do
    it "does not add an error if the record offered is missing" do
      record.offered = nil
      subject.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
    end

    it "does not add an error if offered is valid (number between 0 and 20)" do
      record.offered = 0
      subject.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
      record.offered = 10
      subject.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
      record.offered = 20
      subject.validate_property_number_of_times_relet(record)
      expect(record.errors).to be_empty
    end

    it "does add an error when offered is invalid" do
      record.offered = "invalid"
      subject.validate_property_number_of_times_relet(record)
      expect(record.errors).to_not be_empty
      expect(record.errors["offered"]).to include(match(expected_error))
      record.offered = 21
      subject.validate_property_number_of_times_relet(record)
      expect(record.errors).to_not be_empty
      expect(record.errors["offered"]).to include(match(expected_error))
    end
  end
end
