require "rails_helper"
# rubocop:disable RSpec/RepeatedExample

RSpec.describe UserPolicy do
  subject(:policy) { described_class }

  let(:data_provider) { FactoryBot.create(:user, :data_provider, email: "provider@example.com") }
  let(:data_coordinator) { FactoryBot.create(:user, :data_coordinator) }
  let(:support) { FactoryBot.create(:user, :support) }

  permissions :edit_names? do
    it "allows changing their own name" do
      expect(policy).to permit(data_provider, data_provider)
    end

    it "as a coordinator it allows changing other user's name" do
      expect(policy).to permit(data_coordinator, data_provider)
    end

    it "as a support user it allows changing other user's name" do
      expect(policy).to permit(support, data_provider)
    end
  end

  permissions :edit_emails? do
    it "allows changing their own email" do
      expect(policy).to permit(data_provider, data_provider)
    end

    it "as a coordinator it allows changing other user's email" do
      expect(policy).to permit(data_coordinator, data_provider)
    end

    it "as a support user it allows changing other user's email" do
      expect(policy).to permit(support, data_provider)
    end
  end

  permissions :edit_password? do
    it "as a provider it allows changing their own password" do
      expect(policy).to permit(data_provider, data_provider)
    end

    it "as a coordinator it allows changing their own password" do
      expect(policy).to permit(data_coordinator, data_coordinator)
    end

    it "as a support user it allows changing their own password" do
      expect(policy).to permit(support, support)
    end

    it "as a coordinator it does not allow changing other user's password" do
      expect(policy).not_to permit(data_coordinator, data_provider)
    end

    it "as a support user it does not allow changing other user's password" do
      expect(policy).not_to permit(support, data_provider)
    end
  end

  permissions :edit_roles? do
    it "as a provider it does not allow changing roles" do
      expect(policy).not_to permit(data_provider, data_provider)
    end

    it "as a provider it does not allow changing roles when user is in email allowlist" do
      allow(Rails.application.credentials).to receive(:[]).with(:staging_role_update_email_allowlist).and_return(["example.com"])
      expect(policy).not_to permit(data_provider, data_provider)
    end

    it "as a coordinator allows changing other user's roles" do
      expect(policy).to permit(data_coordinator, data_provider)
    end

    it "as a support user allows changing other user's roles" do
      expect(policy).to permit(support, data_provider)
    end

    context "when on staging" do
      context "and user is in the email allowlist" do
        it "allows changing roles" do
          allow(Rails.env).to receive(:staging?).and_return(true)
          allow(Rails.application.credentials).to receive(:[]).with(:staging_role_update_email_allowlist).and_return(["example.com"])

          expect(policy).to permit(data_provider, data_provider)
        end
      end

      context "and user is not in the email allowlist" do
        it "does not allow changing roles" do
          allow(Rails.env).to receive(:staging?).and_return(true)
          allow(Rails.application.credentials).to receive(:[]).with(:staging_role_update_email_allowlist).and_return(["something.com"])

          expect(policy).not_to permit(data_provider, data_provider)
        end
      end
    end
  end

  permissions :edit_dpo? do
    it "as a provider it does not allow changing dpo" do
      expect(policy).not_to permit(data_provider, data_provider)
    end

    it "as a coordinator allows changing other user's dpo" do
      expect(policy).to permit(data_coordinator, data_provider)
    end

    it "as a support user allows changing other user's dpo" do
      expect(policy).to permit(support, data_provider)
    end
  end

  permissions :edit_key_contact? do
    it "as a provider it does not allow changing key_contact" do
      expect(policy).not_to permit(data_provider, data_provider)
    end

    it "as a coordinator allows changing other user's key_contact" do
      expect(policy).to permit(data_coordinator, data_provider)
    end

    it "as a support user allows changing other user's key_contact" do
      expect(policy).to permit(support, data_provider)
    end
  end

  permissions :edit_organisation? do
    it "as a provider it does not allow changing organisation" do
      expect(policy).not_to permit(data_provider, data_provider)
    end

    it "as a coordinator it does not allow changing organisatio" do
      expect(policy).not_to permit(data_coordinator, data_provider)
    end

    it "as a support user allows changing other user's organisation" do
      expect(policy).to permit(support, data_provider)
    end
  end

  permissions :delete? do
    context "with active user" do
      let(:user) { create(:user, last_sign_in_at: Time.zone.yesterday) }

      it "does not allow deleting a user as a provider" do
        expect(user.status).to eq(:active)
        expect(policy).not_to permit(data_provider, user)
      end

      it "does not allow allows deleting a user as a coordinator" do
        expect(policy).not_to permit(data_coordinator, user)
      end

      it "does not allow deleting a user as a support user" do
        expect(policy).not_to permit(support, user)
      end
    end

    context "with unconfirmed user" do
      let(:user) { create(:user) }

      before do
        user.confirmed_at = nil
        user.save!(validate: false)
      end

      it "does not allow deleting a user as a provider" do
        expect(user.status).to eq(:unconfirmed)
        expect(policy).not_to permit(data_provider, user)
      end

      it "does not allow allows deleting a user as a coordinator" do
        expect(policy).not_to permit(data_coordinator, user)
      end

      it "does not allow deleting a user as a support user" do
        expect(policy).not_to permit(support, user)
      end
    end

    context "with deactivated user" do
      let(:user) { create(:user, active: false) }

      before do
        log = build(:lettings_log, owning_organisation: user.organisation, assigned_to: user, startdate: Time.zone.today - 2.years)
        log.save!(validate: false)
      end

      context "and associated logs in editable collection period" do
        before do
          create(:lettings_log, :sh, owning_organisation: user.organisation, assigned_to: user, startdate: Time.zone.yesterday)
        end

        it "does not allow deleting a user as a provider" do
          expect(policy).not_to permit(data_provider, user)
        end

        it "does not allow allows deleting a user as a coordinator" do
          expect(policy).not_to permit(data_coordinator, user)
        end

        it "does not allow deleting a user as a support user" do
          expect(policy).not_to permit(support, user)
        end
      end

      context "and no associated logs in editable collection period" do
        it "does not allow deleting a user as a provider" do
          expect(policy).not_to permit(data_provider, user)
        end

        it "does not allow allows deleting a user as a coordinator" do
          expect(policy).not_to permit(data_coordinator, user)
        end

        it "allows deleting a user as a support user" do
          expect(policy).to permit(support, user)
        end
      end

      context "and user is the DPO that has signed the agreement" do
        let(:user) { create(:user, active: false, is_dpo: true) }

        before do
          user.organisation.data_protection_confirmation.update!(data_protection_officer: user)
        end

        it "does not allow deleting a user as a provider" do
          expect(policy).not_to permit(data_provider, user)
        end

        it "does not allow allows deleting a user as a coordinator" do
          expect(policy).not_to permit(data_coordinator, user)
        end

        it "does not allow deleting a user as a support user" do
          expect(policy).not_to permit(support, user)
        end
      end

      context "and user is the DPO that hasn't signed the agreement" do
        let(:user) { create(:user, active: false, is_dpo: true, with_dsa: false) }

        it "does not allow deleting a user as a provider" do
          expect(policy).not_to permit(data_provider, user)
        end

        it "does not allow allows deleting a user as a coordinator" do
          expect(policy).not_to permit(data_coordinator, user)
        end

        it "allows deleting a user as a support user" do
          expect(policy).to permit(support, user)
        end
      end
    end
  end
end
# rubocop:enable RSpec/RepeatedExample
