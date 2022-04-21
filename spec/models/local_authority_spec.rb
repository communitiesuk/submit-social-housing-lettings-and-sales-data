require "rails_helper"

RSpec.describe LocalAuthority, type: :model do
  describe "ons code mapping" do
    it "maps ONS code to local authority names" do
      expect(described_class.ons_code_mappings).to be_a(Hash)
      expect(described_class.ons_code_mappings["E07000178"]).to eq("Oxford")
    end
  end
end
