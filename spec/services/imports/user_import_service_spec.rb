require "rails_helper"

RSpec.describe Imports::UserImportService do
  let(:fixture_directory) { "spec/fixtures/softwire_imports/users" }
  let(:old_user_id) { "fc7625a02b24ae16162aa63ae7cb33feeec0c373" }
  let(:old_org_id) { "7c5bd5fb549c09a2c55d7cb90d7ba84927e64618" }
  let(:user_file) { File.open("#{fixture_directory}/#{old_user_id}.xml") }
  let(:storage_service) { instance_double(StorageService) }

  context "when importing users" do
    subject(:import_service) { described_class.new(storage_service) }

    before do
      allow(storage_service).to receive(:list_files)
                                  .and_return(["user_directory/#{old_user_id}.xml"])
      allow(storage_service).to receive(:get_file_io)
                                  .with("user_directory/#{old_user_id}.xml")
                                  .and_return(user_file)
    end

    it "successfully create a user with the expected data" do
      FactoryBot.create(:organisation, old_org_id:)
      import_service.create_users("user_directory")

      user = User.find_by(old_user_id:)
      expect(user.name).to eq("John Doe")
      expect(user.email).to eq("john.doe@gov.uk")
      expect(user.encrypted_password).not_to be_nil
      expect(user.phone).to eq("02012345678")
      expect(user).to be_data_provider
      expect(user.organisation.old_org_id).to eq(old_org_id)
    end

    it "refuses to create a user belonging to a non existing organisation" do
      expect { import_service.create_users("user_directory") }
        .to raise_error(ActiveRecord::RecordInvalid, /Organisation must exist/)
    end

    context "when the user has already been imported previously" do
      before do
        org = FactoryBot.create(:organisation, old_org_id:)
        FactoryBot.create(:user, old_user_id:, organisation: org)
      end

      it "logs that the user already exists" do
        expect(Rails.logger).to receive(:warn)
        import_service.create_users("user_directory")
      end
    end
  end
end
