require "rails_helper"

RSpec.describe Forms::BulkUploadSales::Year do
  subject(:form) { described_class.new }

  describe "#options" do
    before do
      allow(FormHandler.instance).to receive(:sales_forms).and_return({ "current_sales" => instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) })
      allow(FormHandler.instance).to receive(:previous_sales_form).and_return(instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))
      allow(FormHandler.instance).to receive(:next_sales_form).and_return(instance_double(Form, start_date: Time.zone.local(2025, 4, 1)))
    end

    context "when in a crossover period" do
      before do
        allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(true)
      end

      it "returns current and previous years" do
        expect(form.options.map(&:id)).to eql([2024, 2023])
        expect(form.options.map(&:name)).to eql(["2024 to 2025", "2023 to 2024"])
      end
    end

    context "when not in a crossover period" do
      before do
        allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(false)
      end

      it "returns the current year" do
        expect(form.options.map(&:id)).to eql([2024])
        expect(form.options.map(&:name)).to eql(["2024 to 2025"])
      end
    end

    context "when allow_future_form_use is toggled on" do
      before do
        allow(FormHandler.instance).to receive(:sales_in_crossover_period?).and_return(false)
        allow(FeatureToggle).to receive(:allow_future_form_use?).and_return(true)
      end

      after do
        Timecop.return
      end

      it "returns current and next years" do
        expect(form.options.map(&:id)).to eql([2024, 2025])
        expect(form.options.map(&:name)).to eql(["2024 to 2025", "2025 to 2026"])
      end
    end
  end
end
