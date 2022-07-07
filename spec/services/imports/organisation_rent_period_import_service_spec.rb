require "rails_helper"

RSpec.describe Imports::OrganisationRentPeriodImportService do
  let(:fixture_directory) { "spec/fixtures/imports/organisation_rent_periods" }
  let(:old_org_id) { "44026acc7ed5c29516b26f2a5deb639e5e37966d" }
  let(:old_id) { "ebd22326d33e389e9f1bfd546979d2c05f9e68d6" }
  let(:import_file) { File.open("#{fixture_directory}/#{old_id}.xml") }
  let(:storage_service) { instance_double(StorageService) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  context "when importing organisation rent periods" do
    subject(:import_service) { described_class.new(storage_service, logger) }

    before do
      allow(storage_service)
        .to receive(:list_files)
        .and_return(["organisation_rent_period_directory/#{old_id}.xml"])
      allow(storage_service)
        .to receive(:get_file_io)
        .with("organisation_rent_period_directory/#{old_id}.xml")
        .and_return(import_file)
    end

    context "when the organisation in the import file doesn't exist in the system" do
      it "does not create an organisation rent period record" do
        expect(logger).to receive(:error).with(/Organisation must exist/)
        import_service.create_organisation_rent_periods("organisation_rent_period_directory")
      end
    end

    context "when the organisation does exist" do
      before do
        FactoryBot.create(:organisation, old_org_id:)
      end

      it "successfully create an organisation rent period record with the expected data" do
        import_service.create_organisation_rent_periods("organisation_rent_period_directory")
        expect(Organisation.find_by(old_org_id:).organisation_rent_periods.pluck("rent_period")).to eq([1])
      end
    end
  end
end
