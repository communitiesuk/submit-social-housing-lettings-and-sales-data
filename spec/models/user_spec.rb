require "rails_helper"

RSpec.describe User, type: :model do
  describe "#new" do
    let(:user) { FactoryBot.create(:user) }
    let(:organisation) { Organisation.first }

    it "belongs to an organisation" do
      expect(user.organisation).to eq(organisation)
    end
  end
end
