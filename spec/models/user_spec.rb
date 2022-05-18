require "rails_helper"

RSpec.describe User, type: :model do
  describe "#new" do
    let(:user) { FactoryBot.create(:user) }
    let(:other_organisation) { FactoryBot.create(:organisation) }
    let!(:owned_case_log) do
      FactoryBot.create(
        :case_log,
        :completed,
        owning_organisation: user.organisation,
        managing_organisation: other_organisation,
      )
    end
    let!(:managed_case_log) do
      FactoryBot.create(
        :case_log,
        owning_organisation: other_organisation,
        managing_organisation: user.organisation,
      )
    end

    it "belongs to an organisation" do
      expect(user.organisation).to be_a(Organisation)
    end

    it "has owned case logs through their organisation" do
      expect(user.owned_case_logs.first).to eq(owned_case_log)
    end

    it "has managed case logs through their organisation" do
      expect(user.managed_case_logs.first).to eq(managed_case_log)
    end

    it "has case logs through their organisation" do
      expect(user.case_logs.to_a).to eq([owned_case_log, managed_case_log])
    end

    it "has case log status helper methods" do
      expect(user.completed_case_logs.to_a).to eq([owned_case_log])
      expect(user.not_completed_case_logs.to_a).to eq([managed_case_log])
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

    it "is confirmable" do
      allow(DeviseNotifyMailer).to receive(:confirmation_instructions).and_return(OpenStruct.new(deliver: true))
      expect(DeviseNotifyMailer).to receive(:confirmation_instructions).once
      User.create!(
        name: "unconfirmed_user",
        email: "unconfirmed_user@example.com",
        password: "password123",
        organisation: other_organisation,
        role: "data_provider",
      )
    end

    context "when the user is a data provider" do
      it "cannot assign roles" do
        expect(user.assignable_roles).to eq({})
      end
    end

    context "when the user is a data accessor" do
      let(:user) { FactoryBot.create(:user, :data_accessor) }

      it "cannot assign roles" do
        expect(user.assignable_roles).to eq({})
      end
    end

    context "when the user is a data coordinator" do
      let(:user) { FactoryBot.create(:user, :data_coordinator) }

      it "can assign all roles except support" do
        expect(user.assignable_roles).to eq({
          data_accessor: 0,
          data_provider: 1,
          data_coordinator: 2,
        })
      end

      it "can filter case logs by user, year and status" do
        expect(user.case_logs_filters).to eq(%w[status years user])
      end
    end

    context "when the user is a Customer Support person" do
      let(:user) { FactoryBot.create(:user, :support) }
      let!(:other_orgs_log) { FactoryBot.create(:case_log) }

      it "has access to logs from all organisations" do
        expect(user.case_logs.to_a).to eq([owned_case_log, managed_case_log, other_orgs_log])
      end

      it "requires 2FA" do
        expect(user.need_two_factor_authentication?(nil)).to be true
      end

      it "can assign all roles" do
        expect(user.assignable_roles).to eq({
          data_accessor: 0,
          data_provider: 1,
          data_coordinator: 2,
          support: 99,
        })
      end

      it "can filter case logs by user, year, status and organisation" do
        expect(user.case_logs_filters).to eq(%w[status years user organisation])
      end
    end
  end

  describe "paper trail" do
    let(:user) { FactoryBot.create(:user) }

    it "creates a record of changes to a log" do
      expect { user.update!(name: "new test name") }.to change(user.versions, :count).by(1)
    end

    it "allows case logs to be restored to a previous version" do
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
end
