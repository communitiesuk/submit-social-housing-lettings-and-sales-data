require "rails_helper"

RSpec.describe User, type: :model do
  describe "#new" do
    let(:user) { create(:user, old_user_id: "3") }
    let(:other_organisation) { create(:organisation) }

    it "belongs to an organisation" do
      expect(user.organisation).to be_a(Organisation)
    end

    describe "#owned_lettings_logs" do
      let!(:owned_lettings_log) do
        create(
          :lettings_log,
          :completed,
          managing_organisation: other_organisation,
          assigned_to: user,
        )
      end

      it "has owned lettings logs through their organisation" do
        expect(user.owned_lettings_logs.first).to eq(owned_lettings_log)
      end
    end

    describe "#managed_lettings_logs" do
      let!(:managed_lettings_log) do
        create(
          :lettings_log,
          assigned_to: user,
          owning_organisation: other_organisation,
        )
      end

      it "has managed lettings logs through their organisation" do
        expect(user.managed_lettings_logs.first).to eq(managed_lettings_log)
      end
    end

    describe "#lettings_logs" do
      let!(:managed_lettings_log) do
        create(
          :lettings_log,
          :completed,
          managing_organisation: other_organisation,
          assigned_to: user,
        )
      end
      let!(:owned_lettings_log) do
        create(
          :lettings_log,
          assigned_to: user,
          owning_organisation: other_organisation,
        )
      end

      it "has lettings logs through their organisation" do
        expect(user.lettings_logs.to_a).to match_array([owned_lettings_log, managed_lettings_log])
      end

      context "when the user's organisation has absorbed another" do
        let!(:absorbed_org) { create(:organisation, absorbing_organisation_id: user.organisation.id) }
        let!(:absorbed_org_managed_lettings_log) do
          create(
            :lettings_log,
            :completed,
            managing_organisation: absorbed_org,
          )
        end
        let!(:absorbed_org_owned_lettings_log) do
          create(
            :lettings_log,
            owning_organisation: absorbed_org,
          )
        end

        it "has lettings logs through both their organisation and absorbed organisation" do
          expect(user.reload.lettings_logs.to_a).to match_array([owned_lettings_log, managed_lettings_log, absorbed_org_owned_lettings_log, absorbed_org_managed_lettings_log])
        end
      end
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
      FactoryBot.create(:legacy_user, old_user_id: user.old_user_id, user:)
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
      let(:user) { create(:user, :data_coordinator) }

      it "can assign all roles except support" do
        expect(user.assignable_roles).to eq({
          data_provider: 1,
          data_coordinator: 2,
        })
      end

      context "and their organisation does not have managing agents" do
        before do
          user.organisation.update(holds_own_stock: false)
        end

        it "can filter lettings logs by user, year and status" do
          expect(user.logs_filters).to match_array(%w[years status needstypes assigned_to user bulk_upload_id])
        end
      end

      context "and their organisation has managing agents" do
        before do
          create(:organisation_relationship, child_organisation: user.organisation)
        end

        it "can filter lettings logs by user, year, status, managing_organisation and owning_organisation" do
          expect(user.logs_filters).to match_array(%w[years status needstypes assigned_to user managing_organisation owning_organisation bulk_upload_id managing_organisation_text_search owning_organisation_text_search user_text_search])
        end
      end
    end

    context "when the user is a Customer Support person" do
      let(:user) { create(:user, :support) }
      let!(:other_orgs_log) { create(:lettings_log) }
      let!(:owned_lettings_log) do
        create(
          :lettings_log,
          :completed,
          managing_organisation: other_organisation,
          assigned_to: user,
        )
      end
      let!(:managed_lettings_log) do
        create(
          :lettings_log,
          assigned_to: user,
          owning_organisation: other_organisation,
        )
      end

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

      it "can filter lettings logs by user, year, status, managing_organisation and owning_organisation" do
        expect(user.logs_filters).to match_array(%w[years status needstypes assigned_to user owning_organisation managing_organisation bulk_upload_id managing_organisation_text_search owning_organisation_text_search user_text_search])
      end
    end

    context "when the user is in development environment" do
      let(:user) { create(:user, :support) }

      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it "does not require 2FA" do
        expect(user.need_two_factor_authentication?(nil)).to be false
      end
    end

    context "when the user is in review environment" do
      let(:user) { create(:user, :support) }

      before do
        allow(Rails.env).to receive(:development?).and_return(false)
        allow(Rails.env).to receive(:review?).and_return(true)
      end

      it "does not require 2FA" do
        expect(user.need_two_factor_authentication?(nil)).to be false
      end
    end
  end

  describe "paper trail" do
    let(:user) { create(:user) }

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
    let(:organisation_1) { create(:organisation, :without_dpc, name: "A") }
    let(:organisation_2) { create(:organisation, :without_dpc, name: "B") }
    let!(:user_1) { create(:user, name: "Joe Bloggs", email: "joe@example.com", organisation: organisation_1, role: "support", last_sign_in_at: Time.zone.now) }
    let!(:user_2) { create(:user, name: "Jenny Ford", email: "jenny@smith.com", organisation: organisation_1, role: "data_coordinator") }
    let!(:user_3) { create(:user, name: "Tom Smith", email: "tom@example.com", organisation: organisation_1, role: "data_provider") }
    let!(:user_4) { create(:user, name: "Greg Thomas", email: "greg@org2.com", organisation: organisation_2, role: "data_coordinator") }
    let!(:user_5) { create(:user, name: "Adam Thomas", email: "adam@org2.com", organisation: organisation_2, role: "data_coordinator", last_sign_in_at: Time.zone.now) }

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

    context "when filtering by status" do
      before do
        user_2.update!(active: false)
        user_3.update!(active: false, last_sign_in_at: nil)
        user_4.update!(last_sign_in_at: nil)
      end

      context "when filtering by active status" do
        it "returns only active users" do
          expect(described_class.filter_by_status(%w[active]).count).to eq(2)
          expect(described_class.filter_by_status(%w[active])).to include(user_1)
          expect(described_class.filter_by_status(%w[active])).to include(user_5)
        end
      end

      context "when filtering by deactivated status" do
        it "returns only deactivated users" do
          expect(described_class.filter_by_status(%w[deactivated]).count).to eq(2)
          expect(described_class.filter_by_status(%w[deactivated])).to include(user_2)
          expect(described_class.filter_by_status(%w[deactivated])).to include(user_3)
        end
      end

      context "when filtering by unconfirmed status" do
        it "returns only unconfirmed users" do
          expect(described_class.filter_by_status(%w[unconfirmed]).count).to eq(1)
          expect(described_class.filter_by_status(%w[unconfirmed])).to include(user_4)
        end
      end

      context "when filtering by multiple statuses" do
        it "returns relevant users" do
          expect(described_class.filter_by_status(%w[active unconfirmed]).count).to eq(3)
          expect(described_class.filter_by_status(%w[active])).to include(user_1)
          expect(described_class.filter_by_status(%w[active])).to include(user_5)
          expect(described_class.filter_by_status(%w[unconfirmed])).to include(user_4)
        end
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
      let(:error_message) { "Validation failed: Password #{I18n.t('activerecord.errors.models.user.attributes.password.too_short', count: 8)}" }

      it "validates password length" do
        expect { create(:user, password:) }
          .to raise_error(ActiveRecord::RecordInvalid, error_message)
      end
    end

    context "when an invalid email is entered" do
      let(:invalid_email) { "not_an_email" }
      let(:error_message) { "Validation failed: email #{I18n.t('activerecord.errors.models.user.attributes.email.invalid')}" }

      it "validates email format" do
        expect { create(:user, email: invalid_email) }
          .to raise_error(ActiveRecord::RecordInvalid, error_message)
      end
    end

    context "when the email entered has already been used" do
      let(:user) { create(:user) }
      let(:error_message) { "Validation failed: email #{I18n.t('activerecord.errors.models.user.attributes.email.taken')}" }

      it "validates email uniqueness" do
        expect { create(:user, email: user.email) }
          .to raise_error(ActiveRecord::RecordInvalid, error_message)
      end
    end

    context "when a user is added to a merged organisation" do
      let(:merged_organisation) { create(:organisation, merge_date: Time.zone.yesterday) }
      let(:error_message) { "Validation failed: Organisation #{I18n.t('validations.organisation.merged')}" }

      it "validates organisation merge status" do
        expect { create(:user, organisation: merged_organisation) }
          .to raise_error(ActiveRecord::RecordInvalid, error_message)
      end
    end
  end

  describe "delete" do
    let(:user) { create(:user) }

    before do
      create(
        :lettings_log,
        :completed,
        owning_organisation: user.organisation,
        managing_organisation: user.organisation,
        assigned_to: user,
      )

      create(
        :sales_log,
        owning_organisation: user.organisation,
        assigned_to: user,
      )
    end

    context "when the user is deleted" do
      it "owned lettings logs are not deleted as a result" do
        expect { user.destroy! }
          .to change(described_class, :count).by(-1)
          .and change(LettingsLog, :count).by(0)
      end

      it "owned sales logs are not deleted as a result" do
        expect { user.destroy! }
          .to change(described_class, :count).by(-1)
          .and change(SalesLog, :count).by(0)
      end
    end
  end

  describe "#send_data_protection_confirmation_reminder" do
    context "when updating to dpo" do
      let!(:user) { create(:user, is_dpo: false) }

      context "when data_protection_confirmed? is false" do
        it "sends the email" do
          allow(user.organisation).to receive(:data_protection_confirmed?).and_return(false)
          expect { user.update!(is_dpo: true) }.to enqueue_job(ActionMailer::MailDeliveryJob).with(
            "DataProtectionConfirmationMailer",
            "send_confirmation_email",
            "deliver_now",
            args: [user],
          )
        end
      end

      context "when data_protection_confirmed? is true" do
        it "does not send the email" do
          allow(user.organisation).to receive(:data_protection_confirmed?).and_return(true)
          expect { user.update!(is_dpo: true) }.not_to enqueue_job(ActionMailer::MailDeliveryJob)
        end
      end
    end

    context "when updating to non dpo" do
      let!(:user) { create(:user, is_dpo: true) }

      it "does not send the email" do
        expect { user.update!(is_dpo: false) }.not_to enqueue_job(ActionMailer::MailDeliveryJob)
      end
    end

    context "when updating something else" do
      let!(:user) { create(:user) }

      it "does not send the email" do
        expect { user.update!(name: "foobar") }.not_to enqueue_job(ActionMailer::MailDeliveryJob)
      end
    end
  end

  describe "#status" do
    let(:user) { create(:user) }

    it "returns :deactivated for deactivated users" do
      user.active = false

      expect(user.status).to eq(:deactivated)
    end

    it "returns :unconfirmed for a user with no confirmed_at" do
      user.confirmed_at = nil

      expect(user.status).to eq(:unconfirmed)
    end

    it "returns :deactivated for a user with no confirmed_at and active false" do
      user.confirmed_at = nil
      user.active = false

      expect(user.status).to eq(:deactivated)
    end

    it "returns :unconfirmed for a user with no confirmed_at and active true" do
      user.confirmed_at = nil
      user.active = true

      expect(user.status).to eq(:unconfirmed)
    end

    it "returns :active for a user with active status and confirmation date" do
      user.active = true
      user.confirmed_at = Time.zone.yesterday

      expect(user.status).to eq(:active)
    end

    context "when the user is deleted" do
      let(:user) { create(:user, discarded_at: Time.zone.yesterday) }

      it "returns the status of the user" do
        user.destroy!
        expect(user.status).to eq(:deleted)
      end
    end
  end
end
