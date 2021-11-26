require "rails_helper"

RSpec.describe Organisation, type: :model do
  describe "#new" do
    let(:user) { FactoryBot.create(:user) }
    let(:organisation) { user.organisation }

    it "has expected fields" do
      expect(organisation.attribute_names).to include("name", "phone", "org_type")
    end

    it "has users" do
      expect(organisation.users.first).to eq(user)
    end
  end
end
