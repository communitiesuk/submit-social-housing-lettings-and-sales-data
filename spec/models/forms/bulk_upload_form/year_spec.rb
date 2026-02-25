require "rails_helper"

RSpec.describe Forms::BulkUploadForm::Year do
  subject(:form) { described_class.new(log_type:) }

  describe "lettings" do
    let(:log_type) { "lettings" }

    describe "#options" do
      before do
        allow(FormHandler.instance).to receive_messages(lettings_forms: { "current_lettings" => instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }, previous_lettings_form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)), next_lettings_form: instance_double(Form, start_date: Time.zone.local(2025, 4, 1)))
      end

      context "when in a crossover period" do
        before do
          allow(FormHandler.instance).to receive(:lettings_in_crossover_period?).and_return(true)
        end

        it "returns current and previous years" do
          expect(form.options.map(&:id)).to eql([2024, 2023])
          expect(form.options.map(&:name)).to eql(["2024 to 2025", "2023 to 2024"])
        end
      end

      context "when not in a crossover period" do
        before do
          allow(FormHandler.instance).to receive(:lettings_in_crossover_period?).and_return(false)
        end

        it "returns the current year" do
          expect(form.options.map(&:id)).to eql([2024])
          expect(form.options.map(&:name)).to eql(["2024 to 2025"])
        end
      end

      context "when allow_future_form_use is toggled on" do
        before do
          allow(FormHandler.instance).to receive(:lettings_in_crossover_period?).and_return(false)
          allow(FeatureToggle).to receive(:allow_future_form_use?).and_return(true)
        end

        it "returns current and next years" do
          expect(form.options.map(&:id)).to eql([2024, 2025])
          expect(form.options.map(&:name)).to eql(["2024 to 2025", "2025 to 2026"])
        end
      end
    end
  end

  describe "sales" do
    let(:log_type) { "sales" }

    describe "#options" do
      before do
        allow(FormHandler.instance).to receive_messages(sales_forms: { "current_sales" => instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }, previous_sales_form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)), next_sales_form: instance_double(Form, start_date: Time.zone.local(2025, 4, 1)))
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
end
