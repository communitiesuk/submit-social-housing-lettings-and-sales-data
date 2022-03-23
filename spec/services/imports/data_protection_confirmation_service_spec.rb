require "rails_helper"

RSpec.describe Imports::DataProtectionConfirmationImportService do
  let(:fixture_directory) { "spec/fixtures/softwire_imports/data_protection_confirmations" }
  let(:old_org_id) { "7c5bd5fb549c09a2c55d7cb90d7ba84927e64618" }
  let(:old_id) { old_org_id }
  let(:import_file) { File.open("#{fixture_directory}/#{old_id}.xml") }
  let(:storage_service) { instance_double(StorageService) }

  context "when importing data protection confirmations" do
    subject(:import_service) { described_class.new(storage_service) }

    before do
      allow(storage_service)
        .to receive(:list_files)
        .and_return(["data_protection_directory/#{old_id}.xml"])
      allow(storage_service)
        .to receive(:get_file_io)
        .with("data_protection_directory/#{old_id}.xml")
        .and_return(import_file)
    end

    it "successfully create a data protection confirmation record with the expected data" do
      FactoryBot.create(:organisation, old_org_id:)
      import_service.create_data_protection_confirmations("data_protection_directory")

      confirmation = Organisation.find_by(old_org_id:).data_protection_confirmations.last
      expect(confirmation.data_protection_officer.name).to eq("John Doe")
      expect(confirmation.confirmed).to be_truthy
    end

    it "refuses to create a data protection confirmation belonging to a non existing organisation" do
      expect { import_service.create_data_protection_confirmations("data_protection_directory") }
        .to raise_error(ActiveRecord::RecordInvalid, /Organisation must exist/)
    end

    context "when the data protection record has already been imported previously" do
      let(:organisation) { FactoryBot.create(:organisation, old_org_id:) }
      let(:data_protection_officer) { FactoryBot.create(:user, :data_protection_officer, name: "John Doe", organisation:) }
      let!(:data_protection_confirmation) do
        FactoryBot.create(
          :data_protection_confirmation,
          organisation:,
          data_protection_officer:,
          old_org_id:,
          old_id:
        )
      end

      it "logs that the record already exists" do
        expect(Rails.logger).to receive(:warn)
        import_service.create_data_protection_confirmations("data_protection_directory")
      end
    end
  end
end
