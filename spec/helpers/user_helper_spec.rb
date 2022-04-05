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

  describe "pronoun" do
    context "when the current logged in user is the same as the user being viewed" do
      let(:user) { current_user }

      it "returns 'you'" do
        expect(pronoun(user, current_user)).to eq("you")
      end
    end

    context "when the current logged in user is not the same as the user being viewed" do
      it "returns 'they'" do
        expect(pronoun(user, current_user)).to eq("they")
      end
    end
  end
end
