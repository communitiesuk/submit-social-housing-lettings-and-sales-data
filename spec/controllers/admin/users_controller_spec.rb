require "rails_helper"
require_relative "../../support/devise"

describe Admin::UsersController, type: :controller do
  render_views
  let!(:user) { FactoryBot.create(:user) }
  let(:organisation) { FactoryBot.create(:organisation) }
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Users" }
  let(:valid_session) { {} }
  login_admin_user

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
        },
      }
    end

    it "creates a new users" do
      expect { post :create, session: valid_session, params: params }.to change(User, :count).by(1)
    end
  end

  describe "Update users" do
    context "update form" do
      before do
        get :edit, session: valid_session, params: { id: user.id }
      end

      it "shows an edit form" do
        expect(page).to have_field("user_email")
        expect(page).to have_field("user_name")
        expect(page).to have_field("user_organisation_id")
        expect(page).to have_field("user_password")
        expect(page).to have_field("user_password_confirmation")
      end
    end

    context "update" do
      let(:name) { "Pete" }
      let(:params) { { id: user.id, user: { name: name } } }

      before do
        patch :update, session: valid_session, params: params
      end

      it "updates the user without needing to input a password" do
        user.reload
        expect(user.name).to eq(name)
      end
    end
  end
end
