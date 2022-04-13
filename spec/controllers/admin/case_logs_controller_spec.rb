require "rails_helper"
require_relative "../../support/devise"

describe Admin::CaseLogsController, type: :controller do
  before do
    sign_in admin_user
  end

  render_views
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Logs" }
  let(:valid_session) { {} }
  let(:admin_user) { FactoryBot.create(:admin_user) }

  describe "Get case logs" do
    let!(:case_log) { FactoryBot.create(:case_log, :in_progress) }

    before do
      get :index, session: valid_session
    end

    it "returns a table of case logs" do
      expect(page).to have_content(resource_title)
      expect(page).to have_table("index_table_case_logs")
      expect(page).to have_link(case_log.id.to_s)
      expect(page).to have_link(case_log.owning_organisation.name.to_s)
    end
  end

  describe "Create case logs" do
    let(:owning_organisation) { FactoryBot.create(:organisation) }
    let(:managing_organisation) { owning_organisation }
    let(:params) do
      {
        "case_log": {
          "owning_organisation_id": owning_organisation.id,
          "managing_organisation_id": managing_organisation.id,
        },
      }
    end

    it "creates a new case log" do
      expect { post :create, session: valid_session, params: }.to change(CaseLog, :count).by(1)
    end

    it "tracks who created the record" do
      post(:create, session: valid_session, params:)
      created_id = response.location.match(/[0-9]+/)[0]
      whodunnit_actor = CaseLog.find_by(id: created_id).versions.last.actor
      expect(whodunnit_actor).to be_a(AdminUser)
      expect(whodunnit_actor.id).to eq(admin_user.id)
    end
  end

  describe "Update case log" do
    let!(:case_log) { FactoryBot.create(:case_log, :in_progress) }

    context "when viewing the edit form" do
      before do
        get :edit, session: valid_session, params: { id: case_log.id }
      end

      it "has the correct fields" do
        expect(page).to have_field("case_log_age1")
        expect(page).to have_field("case_log_tenant_code")
      end
    end

    context "when updating the case_log" do
      let(:tenant_code) { "New tenant code by Admin" }
      let(:params) { { id: case_log.id, case_log: { tenant_code: } } }

      before do
        patch :update, session: valid_session, params:
      end

      it "updates the case log" do
        case_log.reload
        expect(case_log.tenant_code).to eq(tenant_code)
      end

      it "tracks who updated the record" do
        case_log.reload
        whodunnit_actor = case_log.versions.last.actor
        expect(whodunnit_actor).to be_a(AdminUser)
        expect(whodunnit_actor.id).to eq(admin_user.id)
      end
    end
  end
end
