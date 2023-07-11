require "rails_helper"

RSpec.describe Imports::DataProtectionConfirmationImportService do
  let(:fixture_directory) { "spec/fixtures/imports/dataprotect" }
  let(:old_org_id) { "7c5bd5fb549c09a2c55d7cb90d7ba84927e64618" }
  let(:old_id) { old_org_id }
  let(:import_file) { File.open("#{fixture_directory}/#{old_id}.xml") }
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  context "when importing data protection confirmations" do
    subject(:import_service) { described_class.new(storage_service, logger) }

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
        expect(logger).to receive(:error).with("Organisation must exist")
        import_service.create_data_protection_confirmations("data_protection_directory")
      end
    end

    context "when the organisation does exist" do
      let!(:organisation) { create(:organisation, :without_dpc, old_org_id:, phone: "123") }

      context "when a data protection officer with matching name does not exists for the organisation" do
        it "creates an inactive data protection officer" do
          expect { import_service.create_data_protection_confirmations("data_protection_directory") }
            .to change(User, :count).by(1)
          data_protection_officer = User.find_by(organisation:, is_dpo: true)
          expect(data_protection_officer.confirmed_at).not_to be_nil
          expect(data_protection_officer.active).to be false
        end

        it "successfully create a data protection confirmation record with the expected data", :aggregate_failures do
          import_service.create_data_protection_confirmations("data_protection_directory")
          confirmation = Organisation.find_by(old_org_id:).data_protection_confirmation
          expect(confirmation.confirmed).to be_truthy

          expect(confirmation.data_protection_officer.name).to eq("John Doe")
          expect(confirmation.data_protection_officer_name).to eq("John Doe")
          expect(confirmation.organisation_address).to eq("2 Marsham Street, London, SW1P 4DF")
          expect(confirmation.organisation_name).to eq("DLUHC")
          expect(confirmation.organisation_phone_number).to eq("123")
          expect(Time.zone.local_to_utc(confirmation.created_at)).to eq(Time.utc(2018, 0o6, 0o5, 10, 36, 49))
          expect(Time.zone.local_to_utc(confirmation.signed_at)).to eq(Time.utc(2018, 0o6, 0o5, 10, 36, 49))
        end
      end

      context "when a data protection officer with matching name already exists for the organisation" do
        let!(:data_protection_officer) do
          create(:user, :data_protection_officer, name: "John Doe", organisation:)
        end

        it "successfully creates a data protection confirmation record with the expected data" do
          import_service.create_data_protection_confirmations("data_protection_directory")

          confirmation = Organisation.find_by(old_org_id:).data_protection_confirmation
          expect(confirmation.data_protection_officer.id).to eq(data_protection_officer.id)
          expect(confirmation.confirmed).to be_truthy

          expect(confirmation.data_protection_officer.name).to eq(data_protection_officer.name)
          expect(confirmation.data_protection_officer_name).to eq(data_protection_officer.name)
          expect(confirmation.data_protection_officer_email).to eq(data_protection_officer.email)
          expect(confirmation.organisation_address).to eq("2 Marsham Street, London, SW1P 4DF")
          expect(confirmation.organisation_name).to eq("DLUHC")
          expect(confirmation.organisation_phone_number).to eq("123")
          expect(Time.zone.local_to_utc(confirmation.created_at)).to eq(Time.utc(2018, 0o6, 0o5, 10, 36, 49))
          expect(Time.zone.local_to_utc(confirmation.signed_at)).to eq(Time.utc(2018, 0o6, 0o5, 10, 36, 49))
        end

        context "when the data protection record has already been imported previously" do
          before do
            create(
              :data_protection_confirmation,
              organisation:,
              data_protection_officer:,
              old_org_id:,
              old_id:,
            )
          end

          it "logs that the record already exists" do
            expect(logger).to receive(:warn)
            import_service.create_data_protection_confirmations("data_protection_directory")
          end
        end
      end
    end
  end
end
