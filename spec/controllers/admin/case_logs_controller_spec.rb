require "rails_helper"
require_relative "../../support/devise"
require_relative "../../request_helper"

describe Admin::CaseLogsController, type: :controller do
  before do
    RequestHelper.stub_http_requests
  end
  render_views
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Logs" }
  let(:valid_session) { {} }
  login_admin_user

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
      expect { post :create, session: valid_session, params: params }.to change(CaseLog, :count).by(1)
    end
  end
end
