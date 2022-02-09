require "rails_helper"
require_relative "../../support/devise"

describe Admin::AdminUsersController, type: :controller do
  render_views
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Admin Users" }
  let(:valid_session) { {} }
  let(:signed_in_admin_user) { FactoryBot.create(:admin_user) }

  before do
    sign_in signed_in_admin_user
  end

  describe "Get admin users" do
    before do
      get :index, session: valid_session
    end

    it "returns a table of admin users" do
      expect(page).to have_content(resource_title)
      expect(page).to have_table("index_table_admin_users")
      expect(page).to have_link(AdminUser.first.id.to_s)
    end
  end

  describe "Create admin users" do
    let(:params) { { admin_user: { email: "test2@example.com", password: "pAssword1", phone: "07566126368" } } }

    it "creates a new admin user" do
      expect { post :create, session: valid_session, params: params }.to change(AdminUser, :count).by(1)
    end

    it "tracks who created the record" do
      post :create, session: valid_session, params: params
      created_id = response.location.match(/[0-9]+/)[0]
      whodunnit_actor = AdminUser.find_by(id: created_id).versions.last.actor
      expect(whodunnit_actor).to be_a(AdminUser)
      expect(whodunnit_actor.id).to eq(signed_in_admin_user.id)
    end
  end

  describe "Update admin users" do
    context "when viewing the form" do
      before do
        get :edit, session: valid_session, params: { id: AdminUser.first.id }
      end

      it "shows the correct fields" do
        expect(page).to have_field("admin_user_email")
        expect(page).to have_field("admin_user_password")
        expect(page).to have_field("admin_user_password_confirmation")
      end
    end

    context "when updating an admin user" do
      let(:admin_user) { FactoryBot.create(:admin_user) }
      let(:email) { "new_email@example.com" }
      let(:params) { { id: admin_user.id, admin_user: { email: email } } }

      before do
        patch :update, session: valid_session, params: params
      end

      it "updates the user without needing to input a password" do
        admin_user.reload
        expect(admin_user.email).to eq(email)
      end

      it "tracks who updated the record" do
        admin_user.reload
        whodunnit_actor = admin_user.versions.last.actor
        expect(whodunnit_actor).to be_a(AdminUser)
        expect(whodunnit_actor.id).to eq(signed_in_admin_user.id)
      end
    end
  end
end
