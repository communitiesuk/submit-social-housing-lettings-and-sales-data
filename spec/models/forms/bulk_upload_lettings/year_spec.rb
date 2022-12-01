require "rails_helper"

RSpec.describe Forms::BulkUploadLettings::Year do
  subject(:form) { described_class.new }

  describe "#options" do
    it "returns correct years" do
      expect(form.options.map(&:id)).to eql([2022, 2021])
      expect(form.options.map(&:name)).to eql(%w[2022/2023 2021/2022])
    end
  end
end
