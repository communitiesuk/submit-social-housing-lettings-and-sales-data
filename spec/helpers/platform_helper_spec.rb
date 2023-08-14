require "rails_helper"

RSpec.describe PlatformHelper do
  describe "is_paas?" do
    it "returns true if the VCAP_SERVICES environment variable exists" do
      allow(ENV).to receive(:[]).with("VCAP_SERVICES").and_return("dummy")
      expect(described_class.is_paas?).to eq(true)
    end

    it "returns false if the VCAP_SERVICES environment variable doesn't exist" do
      allow(ENV).to receive(:[]).with("VCAP_SERVICES")
      expect(described_class.is_paas?).to eq(false)
    end
  end
end
