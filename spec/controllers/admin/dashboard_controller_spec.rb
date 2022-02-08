require "rails_helper"
require_relative "../../support/devise"
require_relative "../../request_helper"

describe Admin::DashboardController, type: :controller do
  before do
    RequestHelper.stub_http_requests
    sign_in admin_user
  end

  render_views
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Dashboard" }
  let(:valid_session) { {} }
  let(:admin_user) { FactoryBot.create(:admin_user) }

  describe "Get case logs" do
    before do
      2.times { |_| FactoryBot.create(:case_log, :in_progress) }
      FactoryBot.create(:case_log, :completed)
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
