require "rails_helper"

RSpec.describe UserHelper do
  let(:current_user) { FactoryBot.create(:user, :data_coordinator) }
  let(:user) { FactoryBot.create(:user, :data_coordinator) }

  describe "aliased_user_edit" do
    context "when the current logged in user is the same as the user being viewed" do
      let(:user) { current_user }

      it "returns the edit account path" do
        expect(aliased_user_edit(user, current_user)).to eq(edit_account_path)
      end
    end

    context "when the current logged in user is not the same as the user being viewed" do
      it "returns the edit user path" do
        expect(aliased_user_edit(user, current_user)).to eq(edit_user_path(user))
      end
    end
  end

  describe "perspective" do
    context "when the current logged in user is the same as the user being viewed" do
      let(:user) { current_user }

      it "returns 'Are you'" do
        expect(perspective(user, current_user)).to eq("Are you")
      end
    end

    context "when the current logged in user is not the same as the user being viewed" do
      it "returns 'Is this person'" do
        expect(perspective(user, current_user)).to eq("Is this person")
      end
    end
  end

  describe "change button permissions" do
    context "when the user is a data provider viewing organisation details" do
      let(:current_user) { FactoryBot.create(:user, :data_provider) }

      it "does not allow changing details" do
        expect(can_edit_org?(current_user)).to be false
      end
    end

    context "when the user is a data coordinator viewing organisation details" do
      let(:current_user) { FactoryBot.create(:user, :data_coordinator) }

      it "does not allow changing details" do
        expect(can_edit_org?(current_user)).to be true
      end
    end

    context "when the user is a support user viewing organisation details" do
      let(:current_user) { FactoryBot.create(:user, :support) }

      it "does not allow changing details" do
        expect(can_edit_org?(current_user)).to be true
      end
    end
  end

  describe "organisation_change_warning" do
    context "when user doesn't own any logs" do
      it "returns a message with the number of logs" do
        expected_text = "You’re moving #{user.name} from #{user.organisation.name} to #{current_user.organisation.name}. There are 0 logs assigned to them."
        expect(organisation_change_warning(user, current_user.organisation)).to eq(expected_text)
      end
    end

    context "when user owns 1 lettings log" do
      before do
        create(:lettings_log, assigned_to: user)
      end

      it "returns a message with the number of logs" do
        expected_text = "You’re moving #{user.name} from #{user.organisation.name} to #{current_user.organisation.name}. There is 1 log assigned to them."
        expect(organisation_change_warning(user, current_user.organisation)).to eq(expected_text)
      end
    end

    context "when user owns 1 sales log" do
      before do
        create(:sales_log, assigned_to: user)
      end

      it "returns a message with the number of logs" do
        expected_text = "You’re moving #{user.name} from #{user.organisation.name} to #{current_user.organisation.name}. There is 1 log assigned to them."
        expect(organisation_change_warning(user, current_user.organisation)).to eq(expected_text)
      end
    end

    context "when user owns multiple logs" do
      before do
        create(:lettings_log, assigned_to: user)
        create(:sales_log, assigned_to: user)
      end

      it "returns a message with the number of logs" do
        expected_text = "You’re moving #{user.name} from #{user.organisation.name} to #{current_user.organisation.name}. There are 2 logs assigned to them."
        expect(organisation_change_warning(user, current_user.organisation)).to eq(expected_text)
      end
    end
  end

  describe "organisation_change_confirmation_warning" do
    context "when user owns logs" do
      before do
        create(:lettings_log, assigned_to: user)
      end

      context "with reassign all choice" do
        it "returns the correct message" do
          expected_text = "You’re moving #{user.name} from #{user.organisation.name} to #{current_user.organisation.name}. The stock owner and managing agent on their logs will change to #{current_user.organisation.name}."
          expect(organisation_change_confirmation_warning(user, current_user.organisation, "reassign_all")).to eq(expected_text)
        end
      end

      context "with reassign stock owners choice" do
        it "returns the correct message" do
          expected_text = "You’re moving #{user.name} from #{user.organisation.name} to #{current_user.organisation.name}. The stock owner on their logs will change to #{current_user.organisation.name}."
          expect(organisation_change_confirmation_warning(user, current_user.organisation, "reassign_stock_owner")).to eq(expected_text)
        end
      end

      context "with reassign managing agent choice" do
        it "returns the correct message" do
          expected_text = "You’re moving #{user.name} from #{user.organisation.name} to #{current_user.organisation.name}. The managing agent on their logs will change to #{current_user.organisation.name}."
          expect(organisation_change_confirmation_warning(user, current_user.organisation, "reassign_managing_agent")).to eq(expected_text)
        end
      end

      context "with unassign choice" do
        it "returns the correct message" do
          expected_text = "You’re moving #{user.name} from #{user.organisation.name} to #{current_user.organisation.name}. Their logs will be unassigned."
          expect(organisation_change_confirmation_warning(user, current_user.organisation, "unassign")).to eq(expected_text)
        end
      end
    end

    context "when user doesn't own logs" do
      it "returns the correct message" do
        expected_text = "You’re moving #{user.name} from #{user.organisation.name} to #{current_user.organisation.name}. There are no logs assigned to them."
        expect(organisation_change_confirmation_warning(user, current_user.organisation, "reassign_all")).to eq(expected_text)
      end
    end
  end
end
