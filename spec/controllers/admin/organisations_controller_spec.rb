require "rails_helper"
require_relative "../../support/devise"

describe Admin::OrganisationsController, type: :controller do
  render_views
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Organisations" }
  let(:valid_session) { {} }
  let!(:organisation) { FactoryBot.create(:organisation) }

  login_admin_user

  describe "Organisations" do
    before do
      get :index, session: valid_session
    end

    it "returns a table of admin users" do
      expect(page).to have_content(resource_title)
      expect(page).to have_table("index_table_organisations")
      expect(page).to have_link(organisation.id.to_s)
    end
  end

  describe "Create admin users" do
    let(:params) { { organisation: { name: "DLUHC" } } }

    it "creates a organisation" do
      expect { post :create, session: valid_session, params: params }.to change(Organisation, :count).by(1)
    end
  end

  describe "Update organisation" do
    before do
      get :edit, session: valid_session, params: { id: organisation.id }
    end

    it "creates a new admin users" do
      expect(page).to have_field("organisation_name")
      expect(page).to have_field("organisation_providertype")
      expect(page).to have_field("organisation_phone")
    end
  end
end
