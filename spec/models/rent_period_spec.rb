require "rails_helper"

RSpec.describe RentPeriod, type: :model do
  describe "rent period mapping" do
    let(:form) { Form.new("spec/fixtures/forms/2021_2022.json", "2021_2022") }

    before do
      allow(FormHandler.instance).to receive(:current_form).and_return(form)
    end

    it "maps rent period id to display names" do
      expect(described_class.rent_period_mappings).to be_a(Hash)
      expect(described_class.rent_period_mappings["1"]).to eq({ "value" => "Weekly for 52 weeks" })
    end
  end
end
