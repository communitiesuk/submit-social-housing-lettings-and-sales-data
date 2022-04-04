require "rails_helper"

RSpec.describe FiltersHelper do
  describe "#filter_selected?" do
    context "when no filters are selected" do
      it "returns true for all filters" do
        expect(filter_selected?("completed")).to be_truthy
        expect(filter_selected?("in_progress")).to be_truthy
      end
    end

    context "one filter is selected" do
      before do
        cookies[:case_logs_filters] = { "status": "in_progress" }.to_json
      end

      it "returns false for non selected filters" do
        expect(filter_selected?("completed")).to be_falsey
      end

      it "returns true for selected filter" do
        expect(filter_selected?("in_progress")).to be_truthy
      end
    end
  end
end
