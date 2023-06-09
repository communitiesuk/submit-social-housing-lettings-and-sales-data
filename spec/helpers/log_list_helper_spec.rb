require "rails_helper"

RSpec.describe LogListHelper, type: :helper do
  include FiltersHelper

  describe "#display_delete_logs?" do
    let(:search_term) { nil }

    context "when logged in as a data provider" do
      let(:result) { display_delete_logs?(user, search_term) }
      let(:user) { create(:user) }

      it "returns false if no filters or search are set" do
        allow(self).to receive(:filter_selected?).and_return false
        expect(result).to be false
      end

      it "returns true if the user filter is set to 'yours'" do
        allow(self).to receive(:filter_selected?).with("user", "yours").and_return true
        expect(result).to be true
      end

      it "returns false if any filters other than the user filter are set" do
        allow(self).to receive(:filter_selected?).and_return true
        allow(self).to receive(:filter_selected?).with("user", "yours").and_return false
        expect(result).to be false
      end

      context "when there is a search term present" do
        let(:search_term) { "word" }

        it "still returns false as long as the user filter is not set to yours" do
          allow(self).to receive(:filter_selected?).with("user", "yours").and_return false
          expect(result).to be false
        end
      end
    end

    context "when logged in as a support user or data coordinator" do
      let(:support_user) { create(:user, :support) }
      let(:data_coordinator) { create(:user, :data_coordinator) }
      let(:support_result) { display_delete_logs?(support_user, search_term) }
      let(:coordinator_result) { display_delete_logs?(data_coordinator, search_term) }
      let(:results) { [support_result, coordinator_result] }

      it "returns false if no filters or search are set" do
        allow(self).to receive(:any_filter_selected?).and_return false
        expect(results).to all be false
      end

      it "returns true if any filter is set" do
        allow(self).to receive(:any_filter_selected?).and_return true
        expect(results).to all be true
      end

      context "when there is a search term present" do
        let(:search_term) { "word" }

        it "returns true if no filter is selected" do
          allow(self).to receive(:any_filter_selected?).and_return false
          expect(results).to all be true
        end

        it "returns true if any filter is selected" do
          allow(self).to receive(:any_filter_selected?).and_return true
          expect(results).to all be true
        end
      end
    end
  end
end
