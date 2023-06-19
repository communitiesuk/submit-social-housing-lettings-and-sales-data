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
end
