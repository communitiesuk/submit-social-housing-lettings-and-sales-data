require "rails_helper"

RSpec.describe Imports::UserImportService do
  let(:fixture_directory) { "spec/fixtures/softwire_imports/users" }
  let(:user_file) { File.open("#{fixture_directory}/fc7625a02b24ae16162aa63ae7cb33feeec0c373.xml") }
  let(:storage_service) { instance_double(StorageService) }

  context "when importing users" do
    subject(:import_service) { described_class.new(storage_service) }

    before do
      allow(storage_service).to receive(:list_files)
                                  .and_return(["user_directory/fc7625a02b24ae16162aa63ae7cb33feeec0c373.xml"])
      allow(storage_service).to receive(:get_file_io)
                                  .with("user_directory/fc7625a02b24ae16162aa63ae7cb33feeec0c373.xml")
                                  .and_return(user_file)
    end

    it "successfully create a user with the expected data" do
      FactoryBot.create(:organisation, old_org_id: "7c5bd5fb549c09a2c55d7cb90d7ba84927e64618")
      import_service.create_users("user_directory")

      user = User.find_by(old_user_id: "fc7625a02b24ae16162aa63ae7cb33feeec0c373")
      expect(user.name).to eq("John Doe")
      expect(user.email).to eq("john.doe@gov.uk")
      expect(user.encrypted_password).not_to be_nil
      expect(user.phone).to eq("02012345678")
      expect(user).to be_data_provider
      expect(user.organisation.old_org_id).to eq("7c5bd5fb549c09a2c55d7cb90d7ba84927e64618")
    end

    it "refuses to create a user belonging to a non existing organisation" do
      expect { import_service.create_users("user_directory") }
        .to raise_error(ActiveRecord::RecordInvalid, /Organisation must exist/)
    end
  end
end
