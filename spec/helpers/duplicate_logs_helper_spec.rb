require "rails_helper"

RSpec.describe DuplicateLogsHelper do
  let(:org) { create(:organisation) }
  let(:other_org) { create(:organisation) }
  let(:current_user) { create(:user, organisation: org) }
  let(:user_same_org) { create(:user, organisation: org) }
  let(:user_other_org) { create(:user, organisation: other_org) }
  let(:empty_duplicates) { { lettings: [], sales: [] } }

  let!(:lettings_log) { create(:lettings_log, :duplicate, created_by: current_user) }
  let!(:sales_log) { create(:sales_log, :duplicate, created_by: current_user) }

  describe "#duplicates_for_user" do
    let(:result) { duplicates_for_user(current_user) }

    context "when there are no duplicates" do
      it "returns nil" do
        expect(result).to eq empty_duplicates
      end
    end

    context "when there are duplicates in another org" do
      before do
        create(:lettings_log, :duplicate, created_by: user_other_org)
        create(:sales_log, :duplicate, created_by: user_other_org)
      end

      it "does not locate duplicates" do
        expect(result).to eq empty_duplicates
      end
    end

    context "when another user in the same org has created a duplicate lettings log" do
      let!(:duplicate_lettings_log) { create(:lettings_log, :duplicate, created_by: user_same_org) }

      it "returns the ids of the duplicates in a hash under the lettings key" do
        expect(result).to be_a Hash
        expect(result[:lettings]).to match_array [[lettings_log.id, duplicate_lettings_log.id]]
      end
    end

    context "when another user in the same org has created a duplicate sales log" do
      let!(:duplicate_sales_log) { create(:sales_log, :duplicate, created_by: user_same_org) }

      it "returns the ids of the duplicates in a hash under the sales key" do
        expect(result).to be_a Hash
        expect(result[:sales]).to match_array [[sales_log.id, duplicate_sales_log.id]]
      end
    end

    context "when there are multiple sets of duplicates across lettings and sales" do
      let!(:duplicate_lettings_log) { create(:lettings_log, :duplicate, created_by: user_same_org) }
      let!(:duplicate_sales_log) { create(:sales_log, :duplicate, created_by: user_same_org) }
      let!(:further_sales_log) { create(:sales_log, :duplicate, purchid: "further", created_by: current_user) }
      let!(:further_duplicate_sales_logs) { create_list(:sales_log, 2, :duplicate, purchid: "further", created_by: user_same_org) }

      it "returns them all with no repeats" do
        expected_sales_duplicates_result = [
          [sales_log.id, duplicate_sales_log.id],
          [further_sales_log.id, *further_duplicate_sales_logs.map(&:id)],
        ]

        expect(result[:lettings]).to match_array [[lettings_log.id, duplicate_lettings_log.id]]
        expect(result[:sales]).to match_array expected_sales_duplicates_result
      end
    end
  end
end
