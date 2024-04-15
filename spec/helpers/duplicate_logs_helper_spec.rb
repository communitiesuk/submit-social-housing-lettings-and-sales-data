require "rails_helper"

RSpec.describe DuplicateLogsHelper do
  before do
    Timecop.freeze(Time.zone.local(2024, 3, 1))
    Singleton.__init__(FormHandler)
  end

  after do
    Timecop.return
    Singleton.__init__(FormHandler)
  end

  describe "#duplicates_for_user" do
    let(:org) { create(:organisation) }
    let(:other_org) { create(:organisation) }
    let(:current_user) { create(:user, organisation: org) }
    let(:user_same_org) { create(:user, organisation: org) }
    let(:user_other_org) { create(:user, organisation: other_org) }

    let!(:lettings_log) { create(:lettings_log, :duplicate, created_by: current_user) }
    let!(:sales_log) { create(:sales_log, :duplicate, created_by: current_user) }
    let(:result) { duplicates_for_user(current_user) }

    context "when there are no duplicates" do
      it "returns empty duplicates" do
        expect(result).to eq({ lettings: [], sales: [] })
      end
    end

    context "when there are duplicates in another org" do
      before do
        create(:lettings_log, :duplicate, created_by: user_other_org)
        create(:sales_log, :duplicate, created_by: user_other_org)
      end

      it "does not locate duplicates" do
        expect(result).to eq({ lettings: [], sales: [] })
      end
    end

    context "when another user in the same org has created a duplicate lettings log" do
      let!(:duplicate_lettings_log) { create(:lettings_log, :duplicate, created_by: user_same_org) }

      it "returns the ids of the duplicates in a hash under the lettings key" do
        expect(result).to be_a Hash
        expect(result[:lettings].map(&:sort)).to match_array [[lettings_log.id, duplicate_lettings_log.id]].map(&:sort)
      end
    end

    context "when another user in the same org has created a duplicate sales log" do
      let!(:duplicate_sales_log) { create(:sales_log, :duplicate, created_by: user_same_org) }

      it "returns the ids of the duplicates in a hash under the sales key" do
        expect(result).to be_a Hash
        expect(result[:sales].map(&:sort)).to match_array [[sales_log.id, duplicate_sales_log.id]].map(&:sort)
      end
    end

    context "when there is a set of duplicate lettings logs not associated with the user" do
      before do
        create_list(:lettings_log, 3, :duplicate, tenancycode: "other", owning_organisation: org)
      end

      it "returns the ids of the duplicates in a hash under the lettings key" do
        expect(result).to be_a Hash
        expect(result[:lettings]).to be_empty
      end
    end

    context "when there is a set of duplicate sales logs not associated with the user" do
      before do
        create_list(:sales_log, 3, :duplicate, purchid: "other", owning_organisation: org)
      end

      it "returns the ids of the duplicates in a hash under the sales key" do
        expect(result).to be_a Hash
        expect(result[:sales]).to be_empty
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

        expect(result[:lettings].map(&:sort)).to match_array [[lettings_log.id, duplicate_lettings_log.id]].map(&:sort)
        expect(result[:sales].map(&:sort)).to match_array expected_sales_duplicates_result.map(&:sort)
      end
    end
  end

  describe "#duplicates_for_organisation" do
    let(:organisation) { create(:organisation) }
    let(:sales_logs) { SalesLog.filter_by_organisation(organisation) }

    context "when there are no duplicates" do
      it "returns empty duplicates" do
        expect(duplicates_for_organisation(organisation)).to eq({ lettings: [], sales: [] })
      end
    end

    context "when there are multiple sets of sales duplicates" do
      let!(:duplicate_sales_logs) { create_list(:sales_log, 4, :duplicate, purchid: "set 1", owning_organisation: organisation) }
      let!(:duplicate_sales_logs_too) { create_list(:sales_log, 5, :duplicate, postcode_full: "B1 1BB", owning_organisation: organisation) }
      let!(:duplicate_sales_logs_3) { create_list(:sales_log, 3, :duplicate, age1: 38, owning_organisation: organisation) }

      let!(:duplicate_lettings_logs) { create_list(:lettings_log, 4, :duplicate, tenancycode: "set 1", owning_organisation: organisation) }
      let!(:duplicate_lettings_logs_too) { create_list(:lettings_log, 5, :duplicate, postcode_full: "B1 1BB", owning_organisation: organisation) }
      let!(:duplicate_lettings_logs_3) { create_list(:lettings_log, 3, :duplicate, age1: 38, owning_organisation: organisation) }

      before do
        create_list(:sales_log, 3, :duplicate, discarded_at: Time.zone.now, status: 4, owning_organisation: organisation)
        create_list(:lettings_log, 3, :duplicate, discarded_at: Time.zone.now, status: 4, owning_organisation: organisation)
      end

      it "returns them all with no repeats" do
        expected_sales_duplicates_result = [
          duplicate_sales_logs.map(&:id),
          duplicate_sales_logs_too.map(&:id),
          duplicate_sales_logs_3.map(&:id),
        ]

        expected_lettings_duplicates_result = [
          duplicate_lettings_logs.map(&:id),
          duplicate_lettings_logs_too.map(&:id),
          duplicate_lettings_logs_3.map(&:id),
        ]

        expect(duplicates_for_organisation(organisation)[:lettings].map(&:sort)).to match_array(
          expected_lettings_duplicates_result.map(&:sort).map { |nested_array| match_array(nested_array) },
        )
        expect(duplicates_for_organisation(organisation)[:sales].map(&:sort)).to match_array(
          expected_sales_duplicates_result.map(&:sort).map { |nested_array| match_array(nested_array) },
        )
      end
    end
  end
end
