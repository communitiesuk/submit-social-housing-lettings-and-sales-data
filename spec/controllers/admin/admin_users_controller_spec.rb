require "rails_helper"
require_relative "../../support/devise"

describe Admin::AdminUsersController, type: :controller do
  render_views
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Admin Users" }
  let(:valid_session) { {} }
  login_admin_user

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
    let(:params) { { admin_user: { email: "test2@example.com", password: "pAssword1" } } }

    it "creates a new admin users" do
      expect { post :create, session: valid_session, params: params }.to change(AdminUser, :count).by(1)
    end
  end

  describe "Update admin users" do
    before do
      get :edit, session: valid_session, params: { id: AdminUser.first.id }
    end

    it "creates a new admin users" do
      expect(page).to have_field("admin_user_email")
      expect(page).to have_field("admin_user_password")
      expect(page).to have_field("admin_user_password_confirmation")
    end
  end
end
