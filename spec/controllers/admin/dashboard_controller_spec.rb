require "rails_helper"
require_relative "../../support/devise"
require_relative "../../request_helper"

describe Admin::DashboardController, type: :controller do
  before do
    RequestHelper.stub_http_requests
  end

  render_views
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Dashboard" }
  let!(:case_log) { FactoryBot.create(:case_log, :in_progress) }
  let!(:case_log_2) { FactoryBot.create(:case_log, :in_progress) }
  let!(:completed_case_log) { FactoryBot.create(:case_log, :completed) }
  let(:valid_session) { {} }

  login_admin_user

  describe "Get case logs" do
    before do
      get :index, session: valid_session
    end

    it "returns a dashboard page" do
      expect(page).to have_content(resource_title)
    end

    it "returns a panel of recent case logs" do
      expect(page).to have_xpath("//div[contains(@class, 'panel') and contains(//h3, 'Recent logs')]")
    end

    it "returns a panel of in progress case logs" do
      panel_xpath = "//div[@class='panel' and .//h3[contains(., 'Total logs in progress')]]"
      panel_content_xpath = "#{panel_xpath}//div[@class='panel_contents' and .//p[contains(., 2)]]"
      expect(page).to have_xpath(panel_xpath)
      expect(page).to have_xpath(panel_content_xpath)
    end

    it "returns a panel of completed case logs" do
      panel_xpath = "//div[@class='panel' and .//h3[contains(., 'Total logs completed')]]"
      panel_content_xpath = "#{panel_xpath}//div[@class='panel_contents' and .//p[contains(., 1)]]"
      expect(page).to have_xpath(panel_xpath)
      expect(page).to have_xpath(panel_content_xpath)
    end
  end
end
