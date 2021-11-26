require "rails_helper"

RSpec.describe User, type: :model do
  describe "#new" do
    let(:user) { FactoryBot.create(:user) }

    it "belongs to an organisation" do
      expect(user.organisation).to be_a(Organisation)
    end
  end
end
