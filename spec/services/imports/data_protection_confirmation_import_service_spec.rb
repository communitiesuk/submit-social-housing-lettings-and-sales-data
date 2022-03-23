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

    context "when the organisation in the import file doesn't exist in the system" do
      it "does not create a data protection confirmation" do
        expect { import_service.create_data_protection_confirmations("data_protection_directory") }
          .to raise_error(ActiveRecord::RecordInvalid, /Organisation must exist/)
      end
    end

    context "when the organisation does exist" do
      let!(:organisation) { FactoryBot.create(:organisation, old_org_id:) }

      context "when a data protection officer with matching name does not exists for the organisation" do
        it "creates a data protection officer without sign in credentials" do
          expect { import_service.create_data_protection_confirmations("data_protection_directory") }
            .to change(User, :count).by(1)
          data_protection_officer = User.find_by(organisation:, role: "data_protection_officer")
          expect(data_protection_officer.email).to eq("")
        end

        it "successfully create a data protection confirmation record with the expected data" do
          import_service.create_data_protection_confirmations("data_protection_directory")
          confirmation = Organisation.find_by(old_org_id:).data_protection_confirmations.last
          expect(confirmation.data_protection_officer.name).to eq("John Doe")
          expect(confirmation.confirmed).to be_truthy
          expect(confirmation.created_at).to eq(Time.zone.local(2018, 06, 05, 10, 36, 49))
        end
      end

      context "when a data protection officer with matching name already exists for the organisation" do
        let!(:data_protection_officer) do
          FactoryBot.create(:user, :data_protection_officer, name: "John Doe", organisation:)
        end

        it "successfully creates a data protection confirmation record with the expected data" do
          import_service.create_data_protection_confirmations("data_protection_directory")

          confirmation = Organisation.find_by(old_org_id:).data_protection_confirmations.last
          expect(confirmation.data_protection_officer.id).to eq(data_protection_officer.id)
          expect(confirmation.confirmed).to be_truthy
          expect(confirmation.created_at).to eq(Time.zone.local(2018, 06, 05, 10, 36, 49))
        end

        context "when the data protection record has already been imported previously" do
          before do
            FactoryBot.create(
              :data_protection_confirmation,
              organisation:,
              data_protection_officer:,
              old_org_id:,
              old_id:,
            )
          end

          it "logs that the record already exists" do
            expect(Rails.logger).to receive(:warn)
            import_service.create_data_protection_confirmations("data_protection_directory")
          end
        end
      end
    end
  end
end
