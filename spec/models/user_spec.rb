require "rails_helper"

RSpec.describe User, type: :model do
  describe "#new" do
    let(:user) { FactoryBot.create(:user, old_user_id: "3") }
    let(:other_organisation) { FactoryBot.create(:organisation) }
    let!(:owned_lettings_log) do
      FactoryBot.create(
        :lettings_log,
        :completed,
        owning_organisation: user.organisation,
        managing_organisation: other_organisation,
        created_by: user,
      )
    end
    let!(:managed_lettings_log) do
      FactoryBot.create(
        :lettings_log,
        owning_organisation: other_organisation,
        managing_organisation: user.organisation,
      )
    end

    it "belongs to an organisation" do
      expect(user.organisation).to be_a(Organisation)
    end

    it "has owned lettings logs through their organisation" do
      expect(user.owned_lettings_logs.first).to eq(owned_lettings_log)
    end

    it "has managed lettings logs through their organisation" do
      expect(user.managed_lettings_logs.first).to eq(managed_lettings_log)
    end

    it "has lettings logs through their organisation" do
      expect(user.lettings_logs.to_a).to match_array([owned_lettings_log, managed_lettings_log])
    end

    it "has lettings log status helper methods" do
      expect(user.completed_lettings_logs.to_a).to match_array([owned_lettings_log])
      expect(user.not_completed_lettings_logs.to_a).to match_array([managed_lettings_log])
    end

    it "has a role" do
      expect(user.role).to eq("data_provider")
      expect(user.data_provider?).to be true
      expect(user.data_coordinator?).to be false
    end

    it "is not a key contact by default" do
      expect(user.is_key_contact?).to be false
    end

    it "can be set to key contact" do
      expect { user.is_key_contact! }
        .to change { user.reload.is_key_contact? }.from(false).to(true)
    end

    it "is not a data protection officer by default" do
      expect(user.is_data_protection_officer?).to be false
    end

    it "can be set to data protection officer" do
      expect { user.is_data_protection_officer! }
        .to change { user.reload.is_data_protection_officer? }.from(false).to(true)
    end

    it "is active by default" do
      expect(user.active).to be true
    end

    it "does not require 2FA" do
      expect(user.need_two_factor_authentication?(nil)).to be false
    end

    it "can have one or more legacy users" do
      expect(user.legacy_users.size).to eq(1)
    end

    it "is confirmable" do
      allow(DeviseNotifyMailer).to receive(:confirmation_instructions).and_return(OpenStruct.new(deliver: true))
      expect(DeviseNotifyMailer).to receive(:confirmation_instructions).once
      described_class.create!(
        name: "unconfirmed_user",
        email: "unconfirmed_user@example.com",
        password: "password123",
        organisation: other_organisation,
        role: "data_provider",
      )
    end

    it "does not send a confirmation email to inactive users" do
      expect(DeviseNotifyMailer).not_to receive(:confirmation_instructions)
      described_class.create!(
        name: "unconfirmed_user",
        email: "unconfirmed_user@example.com",
        password: "password123",
        organisation: other_organisation,
        role: "data_provider",
        active: false,
      )
    end

    context "when the user is a data provider" do
      it "cannot assign roles" do
        expect(user.assignable_roles).to eq({})
      end
    end

    context "when the user is a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }

      it "can assign all roles except support" do
        expect(user.assignable_roles).to eq({
          data_provider: 1,
          data_coordinator: 2,
        })
      end

      it "can filter lettings logs by user, year and status" do
        expect(user.logs_filters).to eq(%w[status years user])
      end
    end

    context "when the user is a Customer Support person" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:other_orgs_log) { FactoryBot.create(:lettings_log) }

      it "has access to logs from all organisations" do
        expect(user.lettings_logs.to_a).to match_array([owned_lettings_log, managed_lettings_log, other_orgs_log])
      end

      it "requires 2FA" do
        expect(user.need_two_factor_authentication?(nil)).to be true
      end

      it "can assign all roles" do
        expect(user.assignable_roles).to eq({
          data_provider: 1,
          data_coordinator: 2,
          support: 99,
        })
      end

      it "can filter lettings logs by user, year, status and organisation" do
        expect(user.logs_filters).to eq(%w[status years user organisation])
      end
    end

    context "when the user is in development environment" do
      let(:user) { FactoryBot.create(:user, :support) }

      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it "does not require 2FA" do
        expect(user.need_two_factor_authentication?(nil)).to be false
      end
    end
  end

  describe "paper trail" do
    let(:user) { FactoryBot.create(:user) }

    it "creates a record of changes to a log" do
      expect { user.update!(name: "new test name") }.to change(user.versions, :count).by(1)
    end

    it "allows lettings logs to be restored to a previous version" do
      user.update!(name: "new test name")
      expect(user.paper_trail.previous_version.name).to eq("Danny Rojas")
    end

    it "signing in does not create a new version" do
      expect {
        user.update!(
          last_sign_in_at: Time.zone.now,
          current_sign_in_at: Time.zone.now,
          current_sign_in_ip: "127.0.0.1",
          last_sign_in_ip: "127.0.0.1",
          failed_attempts: 3,
          unlock_token: "dummy",
          locked_at: Time.zone.now,
          reset_password_token: "dummy",
          reset_password_sent_at: Time.zone.now,
          remember_created_at: Time.zone.now,
          sign_in_count: 5,
          updated_at: Time.zone.now,
        )
      }.not_to change(user.versions, :count)
    end
  end

  describe "scopes" do
    let(:organisation_1) { FactoryBot.create(:organisation, name: "A") }
    let(:organisation_2) { FactoryBot.create(:organisation, name: "B") }
    let!(:user_1) { FactoryBot.create(:user, name: "Joe Bloggs", email: "joe@example.com", organisation: organisation_1, role: "support") }
    let!(:user_3) { FactoryBot.create(:user, name: "Tom Smith", email: "tom@example.com", organisation: organisation_1, role: "data_provider") }
    let!(:user_2) { FactoryBot.create(:user, name: "Jenny Ford", email: "jenny@smith.com", organisation: organisation_1, role: "data_coordinator") }
    let!(:user_4) { FactoryBot.create(:user, name: "Greg Thomas", email: "greg@org2.com", organisation: organisation_2, role: "data_coordinator") }
    let!(:user_5) { FactoryBot.create(:user, name: "Adam Thomas", email: "adam@org2.com", organisation: organisation_2, role: "data_coordinator") }

    context "when searching by name" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by_name("Joe").count).to eq(1)
        expect(described_class.search_by_name("joe").count).to eq(1)
      end
    end

    context "when searching by email" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by_email("Example").count).to eq(2)
        expect(described_class.search_by_email("example").count).to eq(2)
      end
    end

    context "when searching by all searchable field" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by("Smith").count).to eq(2)
        expect(described_class.search_by("smith").count).to eq(2)
      end
    end

    context "when using sorted by organisation and role scope" do
      it "returns all users sorted by organisation name, then by role, then alphabetically by name" do
        expect(described_class.sorted_by_organisation_and_role.to_a).to eq([user_1, user_2, user_3, user_5, user_4])
      end
    end
  end

  describe "validate" do
    context "when a user does not have values for required fields" do
      let(:user) { described_class.new }

      before do
        user.validate
      end

      it "validates name, email and organisation presence in the correct order" do
        expect(user.errors.map(&:attribute).uniq).to eq(%i[name email password organisation_id])
      end
    end

    context "when a too short password is entered" do
      let(:password) { "123" }
      let(:error_message) { "Validation failed: Password #{I18n.t('errors.messages.too_short', count: 8)}" }

      it "validates password length" do
        expect { FactoryBot.create(:user, password:) }
          .to raise_error(ActiveRecord::RecordInvalid, error_message)
      end
    end

    context "when an invalid email is entered" do
      let(:invalid_email) { "not_an_email" }
      let(:error_message) { "Validation failed: Email #{I18n.t('activerecord.errors.models.user.attributes.email.invalid')}" }

      it "validates email format" do
        expect { FactoryBot.create(:user, email: invalid_email) }
          .to raise_error(ActiveRecord::RecordInvalid, error_message)
      end
    end

    context "when the email entered has already been used" do
      let(:user) { FactoryBot.create(:user) }
      let(:error_message) { "Validation failed: Email #{I18n.t('activerecord.errors.models.user.attributes.email.taken')}" }

      it "validates email uniqueness" do
        expect { FactoryBot.create(:user, email: user.email) }
          .to raise_error(ActiveRecord::RecordInvalid, error_message)
      end
    end
  end

  describe "delete" do
    let(:user) { FactoryBot.create(:user) }

    before do
      FactoryBot.create(
        :lettings_log,
        :completed,
        owning_organisation: user.organisation,
        managing_organisation: user.organisation,
        created_by: user,
      )

      FactoryBot.create(
        :sales_log,
        owning_organisation: user.organisation,
        created_by: user,
      )
    end

    context "when the user is deleted" do
      it "owned lettings logs are not deleted as a result" do
        expect { user.destroy! }
          .to change(described_class, :count).from(1).to(0)
          .and change(LettingsLog, :count).by(0)
      end

      it "owned sales logs are not deleted as a result" do
        expect { user.destroy! }
          .to change(described_class, :count).from(1).to(0)
          .and change(SalesLog, :count).by(0)
      end
    end
  end
end
