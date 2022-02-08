require "rails_helper"
require_relative "../../support/devise"

describe Admin::UsersController, type: :controller do
  render_views
  let!(:user) { FactoryBot.create(:user) }
  let(:organisation) { FactoryBot.create(:organisation) }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Users" }
  let(:valid_session) { {} }
  let!(:admin_user) { FactoryBot.create(:admin_user) }

  before do
    sign_in admin_user
  end

  describe "Get users" do
    before do
      get :index, session: valid_session
    end

    it "returns a table of users" do
      expect(page).to have_content(resource_title)
      expect(page).to have_table("index_table_users")
      expect(page).to have_link(user.id.to_s)
    end
  end

  describe "Create users" do
    let(:params) do
      {
        user: {
          email: "somethin5@example.com",
          name: "Jane",
          password: "pAssword1",
          organisation_id: organisation.id,
          role: "data_coordinator",
        },
      }
    end

    it "creates a new user" do
      expect { post :create, session: valid_session, params: params }.to change(User, :count).by(1)
    end

    it "tracks who created the record" do
      post :create, session: valid_session, params: params
      created_id = response.location.match(/[0-9]+/)[0]
      whodunnit_actor = User.find_by(id: created_id).versions.last.actor
      expect(whodunnit_actor).to be_a(AdminUser)
      expect(whodunnit_actor.id).to eq(admin_user.id)
    end
  end

  describe "Update users" do
    context "when viewing the edit form" do
      before do
        get :edit, session: valid_session, params: { id: user.id }
      end

      it "has the correct fields" do
        expect(page).to have_field("user_email")
        expect(page).to have_field("user_name")
        expect(page).to have_field("user_organisation_id")
        expect(page).to have_field("user_role")
        expect(page).to have_field("user_password")
        expect(page).to have_field("user_password_confirmation")
      end
    end

    context "when updating the user" do
      let(:name) { "Pete" }
      let(:params) { { id: user.id, user: { name: name } } }

      before do
        patch :update, session: valid_session, params: params
      end

      it "updates the user without needing to input a password" do
        user.reload
        expect(user.name).to eq(name)
      end

      it "tracks who updated the record" do
        user.reload
        whodunnit_actor = user.versions.last.actor
        expect(whodunnit_actor).to be_a(AdminUser)
        expect(whodunnit_actor.id).to eq(admin_user.id)
      end
    end
  end
end
