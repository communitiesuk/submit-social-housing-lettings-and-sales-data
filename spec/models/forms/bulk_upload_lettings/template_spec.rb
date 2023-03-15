require "rails_helper"

RSpec.describe Forms::BulkUploadLettings::Template do
  subject(:form) { described_class.new }

  describe "#options" do
    it "returns correct templates" do
      expect(form.options.map(&:id)).to eq([true, false])
      expect(form.options.map(&:name)).to eq(["Legacy-style template", "New-style template"])
    end
  end
end
