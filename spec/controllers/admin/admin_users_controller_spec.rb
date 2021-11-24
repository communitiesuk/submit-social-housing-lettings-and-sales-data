require "rails_helper"
require_relative "../../support/devise"

describe Admin::AdminUsersController, type: :controller do
  render_views
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Admin Users" }
  let(:valid_session) { {} }
  login_admin_user

  describe "Get case logs" do
    before do
      get :index, session: valid_session
    end

    it "returns a table of admin users" do
      expect(page).to have_content(resource_title)
      expect(page).to have_table("index_table_admin_users")
      expect(page).to have_link(AdminUser.first.id.to_s)
    end
  end
end
