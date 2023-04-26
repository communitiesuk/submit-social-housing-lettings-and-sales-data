require "rails_helper"

RSpec.describe FormPageHelper do
  describe "#action_href" do
    let(:lettings_log) { FactoryBot.build(:lettings_log) }

    it "has an update answer link href helper" do
      lettings_log.id = 1
      expect(action_href(lettings_log, "net_income")).to eq("/lettings-logs/1/net-income?referrer=check_answers")
    end
  end
end
