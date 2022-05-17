require "rails_helper"

RSpec.describe FiltersHelper do
  describe "#filter_selected?" do
    context "when no filters are selected" do
      it "returns false for all filters" do
        expect(filter_selected?("status", "completed")).to be_falsey
        expect(filter_selected?("status", "in_progress")).to be_falsey
      end
    end

    context "when the filter is the user filter but session filters is empty" do
      before do
        session[:case_logs_filters] = {}.to_json
      end

      context "when looking at the all value" do
        it "returns true if no filters have been set yet" do
          expect(filter_selected?("user", :all)).to be true
          expect(filter_selected?("user", :yours)).to be false
        end
      end
    end

    context "when one filter is selected" do
      before do
        session[:case_logs_filters] = { "status": "in_progress" }.to_json
      end

      it "returns false for non selected filters" do
        expect(filter_selected?("status", "completed")).to be false
      end

      it "returns true for selected filter" do
        expect(filter_selected?("status", "in_progress")).to be true
      end
    end

    context "when support user is using the organisation filter" do
      before do
        session[:case_logs_filters] = { "organisation": "1" }.to_json
      end

      it "returns true for the parent organisation_select filter" do
        expect(filter_selected?("organisation_select", :specific_org)).to be true
        expect(filter_selected?("organisation_select", :all)).to be false
      end
    end

    context "when support user has not set the organisation_select filter" do
      before do
        session[:case_logs_filters] = {}.to_json
      end

      it "defaults to all organisations" do
        expect(filter_selected?("organisation_select", :all)).to be true
        expect(filter_selected?("organisation_select", :specific_org)).to be false
      end
    end

    context "when the specific organisation filter is not set" do
      before do
        session[:case_logs_filters] = { "status" => [""], "years" => [""], "user" => "all" }.to_json
      end

      it "marks the all options as checked" do
        expect(filter_selected?("organisation_select", :all)).to be true
        expect(filter_selected?("organisation_select", :specific_org)).to be false
      end
    end
  end
end
