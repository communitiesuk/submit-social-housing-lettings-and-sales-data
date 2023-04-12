require "rails_helper"

RSpec.describe MoneyFormattingHelper do
  describe "#format_money_input" do
    let!(:log) { create(:lettings_log, :completed, brent: 1000) }
    let(:question) { instance_double(Form::Question, id: "brent", prefix:) }

    context "with £ prefix" do
      let(:prefix) { "£" }

      it "returns formatted input" do
        expect(format_money_input(log:, question:)).to eq("1000.00")
      end
    end

    context "with other prefix" do
      let(:prefix) { "other" }

      it "does not format the input" do
        expect(format_money_input(log:, question:)).to eq(BigDecimal(1000))
      end
    end

    context "without prefix" do
      let(:prefix) { nil }

      it "does not format the input" do
        expect(format_money_input(log:, question:)).to eq(BigDecimal(1000))
      end
    end

    context "when value is nil" do
      let(:prefix) { "£" }
      let(:log) { create(:lettings_log, brent: nil) }

      it "does not format the input" do
        expect(format_money_input(log:, question:)).to be_nil
      end
    end
  end
end
