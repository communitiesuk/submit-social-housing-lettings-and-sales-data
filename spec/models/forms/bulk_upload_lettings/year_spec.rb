require "rails_helper"

RSpec.describe Forms::BulkUploadLettings::Year do
  subject(:form) { described_class.new }

  describe "#options" do
    context "when in a crossover period" do
      before do
        Timecop.freeze(2024, 4, 1)
      end

      after do
        Timecop.return
      end

      it "returns current and previous years" do
        expect(form.options.map(&:id)).to eql([2024, 2023])
        expect(form.options.map(&:name)).to eql(%w[2024/2025 2023/2024])
      end
    end

    context "when not in a crossover period" do
      before do
        Timecop.freeze(2024, 3, 1)
      end

      after do
        Timecop.return
      end

      it "returns the current year" do
        expect(form.options.map(&:id)).to eql([2023])
        expect(form.options.map(&:name)).to eql(%w[2023/2024])
      end
    end

    context "when allow_future_form_use is toggled on" do
      before do
        Timecop.freeze(2024, 3, 1)
        allow(FeatureToggle).to receive(:allow_future_form_use?).and_return(true)
      end

      after do
        Timecop.return
      end

      it "returns current and next years" do
        expect(form.options.map(&:id)).to eql([2023, 2024])
        expect(form.options.map(&:name)).to eql(%w[2023/2024 2024/2025])
      end
    end
  end
end
