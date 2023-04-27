require "rails_helper"

RSpec.describe FormPageHelper do
  describe "#action_href" do
    let(:lettings_log) { FactoryBot.build(:lettings_log) }

    it "has an update answer link href helper" do
      lettings_log.id = 1
      expect(action_href(lettings_log, "net_income")).to eq("/lettings-logs/1/net-income?referrer=check_answers")
    end

    it "returns a correct referrer in the url" do
      expect(action_href(lettings_log, "retirement_value_check"), referrer: "interruption_screen").to eq("/lettings-logs/#{lettings_log.id}/retirement-value-check?referrer=interruption_screen")
    end
  end
end
