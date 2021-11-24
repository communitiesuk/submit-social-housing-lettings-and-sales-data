require "rails_helper"
require_relative "../../support/devise"

describe Admin::DashboardController, type: :controller do
  render_views
  let(:page) { Capybara::Node::Simple.new(response.body) }
  let(:resource_title) { "Dashboard" }
  let!(:case_log) { FactoryBot.create(:case_log, :in_progress) }
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
      expect(page).to have_xpath("//div[contains(@class, 'panel') and contains(//h3, 'Recent Case Logs')]")
    end

    it "returns a panel of in progress case logs" do
      expect(page).to have_xpath("//div[@class='panel' and //h3[contains(., 'Total case logs in progress')]]")
    end

    it "returns a panel of completed case logs" do
      expect(page).to have_xpath("//div[@class='panel' and //h3[contains(., 'Total case logs completed')]]")
    end
  end
end
