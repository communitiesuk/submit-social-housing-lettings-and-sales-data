require "rails_helper"
require_relative "../../support/devise"

describe Admin::OrganisationsController, type: :controller do
  render_views
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Organisations" }
  let(:valid_session) { {} }
  let!(:organisation) { FactoryBot.create(:organisation) }
  let!(:admin_user) { FactoryBot.create(:admin_user) }

  before do
    sign_in admin_user
  end

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

  describe "Create organisation" do
    let(:params) { { organisation: { name: "DLUHC" } } }

    it "creates a organisation" do
      expect { post :create, session: valid_session, params: params }.to change(Organisation, :count).by(1)
    end

    it "tracks who created the record" do
      post :create, session: valid_session, params: params
      created_id = response.location.match(/[0-9]+/)[0]
      whodunnit_actor = Organisation.find_by(id: created_id).versions.last.actor
      expect(whodunnit_actor).to be_a(AdminUser)
      expect(whodunnit_actor.id).to eq(admin_user.id)
    end
  end

  describe "Update organisation" do
    context "when viewing the edit form" do
      before do
        get :edit, session: valid_session, params: { id: organisation.id }
      end

      it "has the correct fields" do
        expect(page).to have_field("organisation_name")
        expect(page).to have_field("organisation_provider_type")
        expect(page).to have_field("organisation_phone")
      end
    end

    context "when updating the organisation" do
      let(:name) { "New Org Name by Admin" }
      let(:params) { { id: organisation.id, organisation: { name: name } } }

      before do
        patch :update, session: valid_session, params: params
      end

      it "updates the organisation" do
        organisation.reload
        expect(organisation.name).to eq(name)
      end

      it "tracks who updated the record" do
        organisation.reload
        whodunnit_actor = organisation.versions.last.actor
        expect(whodunnit_actor).to be_a(AdminUser)
        expect(whodunnit_actor.id).to eq(admin_user.id)
      end
    end
  end
end
