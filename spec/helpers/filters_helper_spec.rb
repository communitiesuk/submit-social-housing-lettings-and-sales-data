require "rails_helper"

RSpec.describe FiltersHelper do
  describe "#filter_selected?" do
    context "when no filters are selected" do
      it "returns false for all filters" do
        expect(filter_selected?("status", "completed")).to be_falsey
        expect(filter_selected?("status", "in_progress")).to be_falsey
      end
    end

    context "when one filter is selected" do
      before do
        session[:case_logs_filters] = { "status": "in_progress" }.to_json
      end

      it "returns false for non selected filters" do
        expect(filter_selected?("status", "completed")).to be_falsey
      end

      it "returns true for selected filter" do
        expect(filter_selected?("status", "in_progress")).to be_truthy
      end
    end
  end
end
