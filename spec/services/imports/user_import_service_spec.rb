require "rails_helper"

RSpec.describe Imports::UserImportService do
  let(:fixture_directory) { "spec/fixtures/imports/users" }
  let(:old_user_id) { "fc7625a02b24ae16162aa63ae7cb33feeec0c373" }
  let(:old_org_id) { "7c5bd5fb549c09a2c55d7cb90d7ba84927e64618" }
  let(:user_file) { File.open("#{fixture_directory}/#{old_user_id}.xml") }
  let(:storage_service) { instance_double(StorageService) }
  let(:logger) { instance_double(ActiveSupport::Logger) }
  let(:notify_client) { instance_double(Notifications::Client) }
  let(:devise_notify_mailer) { DeviseNotifyMailer.new }

  before do
    allow(DeviseNotifyMailer).to receive(:new).and_return(devise_notify_mailer)
    allow(devise_notify_mailer).to receive(:notify_client).and_return(notify_client)
    allow(notify_client).to receive(:send_email).and_return(true)
  end

  context "when importing users" do
    subject(:import_service) { described_class.new(storage_service, logger) }

    before do
      allow(storage_service).to receive(:list_files)
                                  .and_return(["user_directory/#{old_user_id}.xml"])
      allow(storage_service).to receive(:get_file_io)
                                  .with("user_directory/#{old_user_id}.xml")
                                  .and_return(user_file)
      allow(logger).to receive(:info)
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
      expect(user.is_key_contact?).to be false
      expect(user.active).to be true
    end

    it "refuses to create a user belonging to a non existing organisation" do
      expect(logger).to receive(:error).with(/Organisation must exist/)
      import_service.create_users("user_directory")
    end

    context "when the user is a data coordinator" do
      let(:old_user_id) { "d4729b1a5dfb68bb1e01c08445830c0add40907c" }

      it "sets their role correctly" do
        FactoryBot.create(:organisation, old_org_id:)
        import_service.create_users("user_directory")
        expect(User.find_by(old_user_id:)).to be_data_coordinator
      end
    end

    context "when the user is a data protection officer" do
      let(:old_user_id) { "10c887710550844e2551b3e0fb88dc9b4a8a642b" }

      it "marks them as a data protection officer" do
        FactoryBot.create(:organisation, old_org_id:)
        import_service.create_users("user_directory")

        user = User.find_by(old_user_id:)
        expect(user.is_data_protection_officer?).to be true
      end
    end

    context "when the user was a 'Key Performance Contact' in the old system" do
      let(:old_user_id) { "d4729b1a5dfb68bb1e01c08445830c0add40907c" }

      it "marks them as a key contact" do
        FactoryBot.create(:organisation, old_org_id:)
        import_service.create_users("user_directory")

        user = User.find_by(old_user_id:)
        expect(user.is_key_contact?).to be true
      end
    end

    context "when the user was a 'eCORE Contact' in the old system" do
      let(:old_user_id) { "d6717836154cd9a58f9e2f1d3077e3ab81e07613" }

      it "marks them as a key contact" do
        FactoryBot.create(:organisation, old_org_id:)
        import_service.create_users("user_directory")

        user = User.find_by(old_user_id:)
        expect(user.is_key_contact?).to be true
      end
    end

    context "when the user has already been imported previously" do
      before do
        org = FactoryBot.create(:organisation, old_org_id:)
        FactoryBot.create(:user, old_user_id:, organisation: org)
      end

      it "logs that the user already exists" do
        expect(logger).to receive(:warn)
        import_service.create_users("user_directory")
      end
    end

    context "when a user has already been imported with that email" do
      let!(:org) { FactoryBot.create(:organisation, old_org_id:) }
      let!(:user) { FactoryBot.create(:user, :data_provider, organisation: org, email: "john.doe@gov.uk") }

      context "when the duplicate role is higher than the original role" do
        let(:old_user_id) { "d4729b1a5dfb68bb1e01c08445830c0add40907c" }

        it "upgrades their role" do
          import_service.create_users("user_directory")
          expect(user.reload).to be_data_coordinator
        end

        it "does not create a new record" do
          expect { import_service.create_users("user_directory") }
            .not_to change(User, :count)
        end
      end

      context "when the duplicate role is lower than the original role" do
        let!(:user) { FactoryBot.create(:user, :data_coordinator, organisation: org, email: "john.doe@gov.uk") }
        let(:old_user_id) { "fc7625a02b24ae16162aa63ae7cb33feeec0c373" }

        it "does not change their role" do
          expect { import_service.create_users("user_directory") }
            .not_to(change { user.reload.role })
        end

        it "does not create a new record" do
          expect { import_service.create_users("user_directory") }
            .not_to change(User, :count)
        end
      end

      context "when the duplicate record is a data protection officer role" do
        let!(:user) { FactoryBot.create(:user, :data_coordinator, organisation: org, email: "john.doe@gov.uk") }
        let(:old_user_id) { "10c887710550844e2551b3e0fb88dc9b4a8a642b" }

        it "marks them as a data protection officer" do
          import_service.create_users("user_directory")
          expect(user.reload.is_data_protection_officer?).to be true
        end

        it "does not create a new record" do
          expect { import_service.create_users("user_directory") }
            .not_to change(User, :count)
        end
      end

      context "when the user was deactivated in the old system" do
        let(:old_user_id) { "9ed81a262215a1634f0809effa683e38924d8bcb" }

        it "marks them as not active" do
          import_service.create_users("user_directory")
          expect(User.find_by(old_user_id:).active).to be false
        end
      end
    end
  end
end
