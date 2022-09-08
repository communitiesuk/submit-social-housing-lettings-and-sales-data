require "rails_helper"

RSpec.describe LettingsLogsController, type: :request do
  describe "index" do
    let(:user) { FactoryBot.create(:user) }
    let(:page) { Capybara::Node::Simple.new(response.body) }

    before do
      sign_in user
      FactoryBot.create_list(:lettings_log, 3, :completed, owning_organisation: user.organisation, created_by: user)
      FactoryBot.create_list(:sales_log, 3, owning_organisation: user.organisation, created_by: user)
    end

    it "shows both lettings and sales logs" do
      get "/logs"
      expect(page).to have_content("6 total logs")
    end
  end
end
