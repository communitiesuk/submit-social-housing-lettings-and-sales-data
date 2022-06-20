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
    context "when the user is a data provider viewing their own details" do
      let(:current_user) { FactoryBot.create(:user, :data_provider) }
      let(:user) { current_user }

      it "allows changing name" do
        expect(can_edit_names?(user, current_user)).to be true
      end

      it "allows changing email" do
        expect(can_edit_emails?(user, current_user)).to be true
      end

      it "allows changing password" do
        expect(can_edit_password?(user, current_user)).to be true
      end

      it "does not allow changing roles" do
        expect(can_edit_roles?(user, current_user)).to be false
      end

      it "does not allow changing dpo" do
        expect(can_edit_dpo?(user, current_user)).to be false
      end

      it "does not allow changing key contact" do
        expect(can_edit_key_contact?(user, current_user)).to be false
      end
    end

    context "when the user is a data coordinator viewing another user's details" do
      it "allows changing name" do
        expect(can_edit_names?(user, current_user)).to be true
      end

      it "allows changing email" do
        expect(can_edit_emails?(user, current_user)).to be true
      end

      it "allows changing password" do
        expect(can_edit_password?(user, current_user)).to be false
      end

      it "does not allow changing roles" do
        expect(can_edit_roles?(user, current_user)).to be true
      end

      it "does not allow changing dpo" do
        expect(can_edit_dpo?(user, current_user)).to be true
      end

      it "does not allow changing key contact" do
        expect(can_edit_key_contact?(user, current_user)).to be true
      end

      context "when the user is a data coordinator viewing their own details" do
        let(:user) { current_user }

        it "allows changing password" do
          expect(can_edit_password?(user, current_user)).to be true
        end
      end
    end

    context "when the user is a support user viewing another user's details" do
      let(:current_user) { FactoryBot.create(:user, :support) }

      it "allows changing name" do
        expect(can_edit_names?(user, current_user)).to be true
      end

      it "allows changing email" do
        expect(can_edit_emails?(user, current_user)).to be true
      end

      it "allows changing password" do
        expect(can_edit_password?(user, current_user)).to be false
      end

      it "does not allow changing roles" do
        expect(can_edit_roles?(user, current_user)).to be true
      end

      it "does not allow changing dpo" do
        expect(can_edit_dpo?(user, current_user)).to be true
      end

      it "does not allow changing key contact" do
        expect(can_edit_key_contact?(user, current_user)).to be true
      end

      context "when the user is a support user viewing their own details" do
        let(:user) { current_user }

        it "allows changing password" do
          expect(can_edit_password?(user, current_user)).to be true
        end
      end
    end

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
end
