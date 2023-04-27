require "rails_helper"

RSpec.describe FormPageHelper do
  describe "#action_href" do
    let(:lettings_log) { FactoryBot.create(:lettings_log) }

    it "has an update answer link href helper" do
      expect(action_href(lettings_log, "net_income")).to eq("/lettings-logs/#{lettings_log.id}/net-income?referrer=check_answers")
    end

    it "returns a correct referrer in the url" do
      expect(action_href(lettings_log, "retirement_value_check", "interruption_screen")).to eq("/lettings-logs/#{lettings_log.id}/retirement-value-check?referrer=interruption_screen")
    end
  end
end
