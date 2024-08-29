require "rails_helper"

RSpec.describe MergeRequest, type: :model do
  describe ".visible" do
    let(:open_collection_period_start_date) { 1.year.ago }
    let!(:merged_recent) { create(:merge_request, request_merged: true, merge_date: 3.months.ago) }
    let!(:merged_old) { create(:merge_request, request_merged: true, merge_date: 18.months.ago) }
    let!(:not_merged) { create(:merge_request, request_merged: false) }

    before do
      allow(FormHandler.instance).to receive(:start_date_of_earliest_open_collection_period).and_return(open_collection_period_start_date)
    end

    it "includes merged requests with merge dates after the open collection period start date" do
      expect(described_class.visible).to include(merged_recent)
    end

    it "excludes merged requests with merge dates before the open collection period start date" do
      expect(described_class.visible).not_to include(merged_old)
    end

    it "includes not_merged requests" do
      expect(described_class.visible).to include(not_merged)
    end
  end

  describe "#discard!" do
    let(:merge_request) { create(:merge_request) }

    it "sets the discarded_at field" do
      merge_request.discard!
      expect(merge_request.discarded_at).not_to be_nil
    end

    it "does not delete the record" do
      merge_request.discard!
      expect(merge_request).to be_persisted
    end

    it "is not visible in the visible scope" do
      merge_request.discard!
      expect(described_class.visible).not_to include(merge_request)
    end
  end

  describe "#status" do
    it "returns the correct status for deleted merge request" do
      merge_request = build(:merge_request, id: 1, discarded_at: Time.zone.today)
      expect(merge_request.status).to eq MergeRequest::STATUS[:deleted]
    end

    it "returns the correct status for a merged request" do
      merge_request = build(:merge_request, id: 1, request_merged: true)
      expect(merge_request.status).to eq MergeRequest::STATUS[:request_merged]
    end

    it "returns the correct status for a ready to merge request" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: create(:organisation), merge_date: Time.zone.today)
      create(:merge_request_organisation, merge_request:)
      expect(merge_request.status).to eq MergeRequest::STATUS[:ready_to_merge]
    end

    it "returns the merge issues if dsa is not signed for absorbing organisation" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: create(:organisation, with_dsa: false), merge_date: Time.zone.today)
      create(:merge_request_organisation, merge_request:)
      expect(merge_request.status).to eq MergeRequest::STATUS[:merge_issues]
    end

    it "returns the incomplete if absorbing organisation is missing" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: nil, merge_date: Time.zone.today)
      create(:merge_request_organisation, merge_request:)
      expect(merge_request.status).to eq MergeRequest::STATUS[:incomplete]
    end

    it "returns the incomplete if merge requests organisation is missing" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: create(:organisation), merge_date: Time.zone.today)
      expect(merge_request.status).to eq MergeRequest::STATUS[:incomplete]
    end

    it "returns the incomplete if merge date is missing" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: create(:organisation))
      create(:merge_request_organisation, merge_request:)
      expect(merge_request.status).to eq MergeRequest::STATUS[:incomplete]
    end

    it "returns processing if merge is processing" do
      merge_request = build(:merge_request, id: 1, absorbing_organisation: create(:organisation), processing: true)
      create(:merge_request_organisation, merge_request:)
      expect(merge_request.status).to eq MergeRequest::STATUS[:processing]
    end
  end

  describe "#organisations_with_users" do
    context "when absorbing organisation has users" do
      let(:merge_request) { create(:merge_request, absorbing_organisation:) }
      let(:absorbing_organisation) { create(:organisation) }

      before do
        create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_1)
        create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_2)
      end

      context "and some merging organisations have users" do
        let(:merging_organisation_1) { create(:organisation) }
        let(:merging_organisation_2) { create(:organisation, with_dsa: false) }

        it "returns correct organisations with users" do
          expect(absorbing_organisation.users.count).to eq(1)
          expect(merging_organisation_1.users.count).to eq(1)
          expect(merging_organisation_2.users.count).to eq(0)

          expect(merge_request.organisations_with_users.count).to eq(2)
          expect(merge_request.organisations_with_users).to include(merging_organisation_1)
          expect(merge_request.organisations_with_users).to include(absorbing_organisation)
        end
      end

      context "and no merging organisations have users" do
        let(:merging_organisation_1) { create(:organisation, with_dsa: false) }
        let(:merging_organisation_2) { create(:organisation, with_dsa: false) }

        it "returns correct organisations with users" do
          expect(absorbing_organisation.users.count).to eq(1)
          expect(merging_organisation_1.users.count).to eq(0)
          expect(merging_organisation_2.users.count).to eq(0)

          expect(merge_request.organisations_with_users.count).to eq(1)
          expect(merge_request.organisations_with_users).to include(absorbing_organisation)
        end
      end
    end

    context "when absorbing organisation has no users" do
      let(:merge_request) { create(:merge_request, absorbing_organisation:) }
      let(:absorbing_organisation) { create(:organisation, with_dsa: false) }

      before do
        create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_1)
        create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_2)
      end

      context "and some merging organisations have users" do
        let(:merging_organisation_1) { create(:organisation) }
        let(:merging_organisation_2) { create(:organisation, with_dsa: false) }

        it "returns correct organisations with users" do
          expect(merging_organisation_1.users.count).to eq(1)
          expect(absorbing_organisation.users.count).to eq(0)
          expect(merging_organisation_2.users.count).to eq(0)

          expect(merge_request.organisations_with_users.count).to eq(1)
          expect(merge_request.organisations_with_users).to include(merging_organisation_1)
        end
      end

      context "and no merging organisations have users" do
        let(:merging_organisation_1) { create(:organisation, with_dsa: false) }
        let(:merging_organisation_2) { create(:organisation, with_dsa: false) }

        it "returns correct organisations with users" do
          expect(absorbing_organisation.users.count).to eq(0)
          expect(merging_organisation_1.users.count).to eq(0)
          expect(merging_organisation_2.users.count).to eq(0)

          expect(merge_request.organisations_with_users.count).to eq(0)
        end
      end
    end
  end

  describe "#organisations_with_schemes" do
    let(:merge_request) { create(:merge_request, absorbing_organisation:) }
    let(:absorbing_organisation) { create(:organisation) }
    let(:merging_organisation_1) { create(:organisation) }
    let(:merging_organisation_2) { create(:organisation) }

    before do
      create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_1)
      create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_2)
    end

    context "when absorbing organisation has schemes" do
      before do
        create(:scheme, owning_organisation: absorbing_organisation)
      end

      context "and some merging organisations have schemes" do
        before do
          create(:scheme, owning_organisation: merging_organisation_1)
        end

        it "returns correct organisations with schemes" do
          expect(absorbing_organisation.owned_schemes.count).to eq(1)
          expect(merging_organisation_1.owned_schemes.count).to eq(1)
          expect(merging_organisation_2.owned_schemes.count).to eq(0)

          expect(merge_request.organisations_with_schemes.count).to eq(2)
          expect(merge_request.organisations_with_schemes).to include(merging_organisation_1)
          expect(merge_request.organisations_with_schemes).to include(absorbing_organisation)
        end
      end

      context "and no merging organisations have schemes" do
        it "returns correct organisations with schemes" do
          expect(absorbing_organisation.owned_schemes.count).to eq(1)
          expect(merging_organisation_1.owned_schemes.count).to eq(0)
          expect(merging_organisation_2.owned_schemes.count).to eq(0)

          expect(merge_request.organisations_with_schemes.count).to eq(1)
          expect(merge_request.organisations_with_schemes).to include(absorbing_organisation)
        end
      end
    end

    context "when absorbing organisation has no schemes" do
      context "and some merging organisations have schemes" do
        before do
          create(:scheme, owning_organisation: merging_organisation_1)
        end

        it "returns correct organisations with schemes" do
          expect(merging_organisation_1.owned_schemes.count).to eq(1)
          expect(absorbing_organisation.owned_schemes.count).to eq(0)
          expect(merging_organisation_2.owned_schemes.count).to eq(0)

          expect(merge_request.organisations_with_schemes.count).to eq(1)
          expect(merge_request.organisations_with_schemes).to include(merging_organisation_1)
        end
      end

      context "and no merging organisations have schemes" do
        it "returns correct organisations with schemes" do
          expect(absorbing_organisation.owned_schemes.count).to eq(0)
          expect(merging_organisation_1.owned_schemes.count).to eq(0)
          expect(merging_organisation_2.owned_schemes.count).to eq(0)

          expect(merge_request.organisations_with_schemes.count).to eq(0)
        end
      end
    end
  end

  describe "#organisations_without_users" do
    context "when absorbing organisation has users" do
      let(:merge_request) { create(:merge_request, absorbing_organisation:) }
      let(:absorbing_organisation) { create(:organisation) }

      before do
        create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_1)
        create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_2)
      end

      context "and some merging organisations have users" do
        let(:merging_organisation_1) { create(:organisation) }
        let(:merging_organisation_2) { create(:organisation, with_dsa: false) }

        it "returns correct organisations with users" do
          expect(absorbing_organisation.users.count).to eq(1)
          expect(merging_organisation_1.users.count).to eq(1)
          expect(merging_organisation_2.users.count).to eq(0)

          expect(merge_request.organisations_without_users.count).to eq(1)
          expect(merge_request.organisations_without_users).to include(merging_organisation_2)
        end
      end

      context "and no merging organisations have users" do
        let(:merging_organisation_1) { create(:organisation, with_dsa: false) }
        let(:merging_organisation_2) { create(:organisation, with_dsa: false) }

        it "returns correct organisations with users" do
          expect(absorbing_organisation.users.count).to eq(1)
          expect(merging_organisation_1.users.count).to eq(0)
          expect(merging_organisation_2.users.count).to eq(0)

          expect(merge_request.organisations_without_users.count).to eq(2)
          expect(merge_request.organisations_without_users).to include(merging_organisation_1)
          expect(merge_request.organisations_without_users).to include(merging_organisation_2)
        end
      end
    end

    context "when absorbing organisation has no users" do
      let(:merge_request) { create(:merge_request, absorbing_organisation:) }
      let(:absorbing_organisation) { create(:organisation, with_dsa: false) }

      before do
        create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_1)
        create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_2)
      end

      context "and some merging organisations have users" do
        let(:merging_organisation_1) { create(:organisation) }
        let(:merging_organisation_2) { create(:organisation, with_dsa: false) }

        it "returns correct organisations with users" do
          expect(merging_organisation_1.users.count).to eq(1)
          expect(absorbing_organisation.users.count).to eq(0)
          expect(merging_organisation_2.users.count).to eq(0)

          expect(merge_request.organisations_without_users.count).to eq(2)
          expect(merge_request.organisations_without_users).to include(absorbing_organisation)
          expect(merge_request.organisations_without_users).to include(merging_organisation_2)
        end
      end

      context "and no merging organisations have users" do
        let(:merging_organisation_1) { create(:organisation, with_dsa: false) }
        let(:merging_organisation_2) { create(:organisation, with_dsa: false) }

        it "returns correct organisations with users" do
          expect(absorbing_organisation.users.count).to eq(0)
          expect(merging_organisation_1.users.count).to eq(0)
          expect(merging_organisation_2.users.count).to eq(0)

          expect(merge_request.organisations_without_users.count).to eq(3)
          expect(merge_request.organisations_without_users).to include(absorbing_organisation)
          expect(merge_request.organisations_without_users).to include(merging_organisation_1)
          expect(merge_request.organisations_without_users).to include(merging_organisation_2)
        end
      end
    end
  end

  describe "#organisations_without_schemes" do
    let(:merge_request) { create(:merge_request, absorbing_organisation:) }
    let(:absorbing_organisation) { create(:organisation) }
    let(:merging_organisation_1) { create(:organisation) }
    let(:merging_organisation_2) { create(:organisation) }

    before do
      create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_1)
      create(:merge_request_organisation, merge_request:, merging_organisation: merging_organisation_2)
    end

    context "when absorbing organisation has schemes" do
      before do
        create(:scheme, owning_organisation: absorbing_organisation)
      end

      context "and some merging organisations have schemes" do
        before do
          create(:scheme, owning_organisation: merging_organisation_1)
        end

        it "returns correct organisations with schemes" do
          expect(absorbing_organisation.owned_schemes.count).to eq(1)
          expect(merging_organisation_1.owned_schemes.count).to eq(1)
          expect(merging_organisation_2.owned_schemes.count).to eq(0)

          expect(merge_request.organisations_without_schemes.count).to eq(1)
          expect(merge_request.organisations_without_schemes).to include(merging_organisation_2)
        end
      end

      context "and no merging organisations have schemes" do
        it "returns correct organisations with schemes" do
          expect(absorbing_organisation.owned_schemes.count).to eq(1)
          expect(merging_organisation_1.owned_schemes.count).to eq(0)
          expect(merging_organisation_2.owned_schemes.count).to eq(0)

          expect(merge_request.organisations_without_schemes.count).to eq(2)
          expect(merge_request.organisations_without_schemes).to include(merging_organisation_1)
          expect(merge_request.organisations_without_schemes).to include(merging_organisation_2)
        end
      end
    end

    context "when absorbing organisation has no schemes" do
      context "and some merging organisations have schemes" do
        before do
          create(:scheme, owning_organisation: merging_organisation_1)
        end

        it "returns correct organisations with schemes" do
          expect(merging_organisation_1.owned_schemes.count).to eq(1)
          expect(absorbing_organisation.owned_schemes.count).to eq(0)
          expect(merging_organisation_2.owned_schemes.count).to eq(0)

          expect(merge_request.organisations_without_schemes.count).to eq(2)
          expect(merge_request.organisations_without_schemes).to include(absorbing_organisation)
          expect(merge_request.organisations_without_schemes).to include(merging_organisation_2)
        end
      end

      context "and no merging organisations have schemes" do
        it "returns correct organisations with schemes" do
          expect(absorbing_organisation.owned_schemes.count).to eq(0)
          expect(merging_organisation_1.owned_schemes.count).to eq(0)
          expect(merging_organisation_2.owned_schemes.count).to eq(0)

          expect(merge_request.organisations_without_schemes.count).to eq(3)
          expect(merge_request.organisations_without_schemes).to include(absorbing_organisation)
          expect(merge_request.organisations_without_schemes).to include(merging_organisation_1)
          expect(merge_request.organisations_without_schemes).to include(merging_organisation_2)
        end
      end
    end
  end

  describe "relationship outcomes" do
    let(:stock_owner1) { create(:organisation, name: "Stock owner 1") }
    let(:stock_owner2) { create(:organisation, name: "Stock owner 2") }
    let(:stock_owner3) { create(:organisation, name: "Stock owner 3") }
    let(:managing_agent1) { create(:organisation, name: "Managing agent 1") }
    let(:managing_agent2) { create(:organisation, name: "Managing agent 2") }
    let(:absorbing_organisation) { create(:organisation, name: "Absorbing Org") }
    let(:merging_organisations) { create_list(:organisation, 2) { |org, i| org.name = "Dummy Org #{i + 1}" } }
    let(:merge_request) { create(:merge_request, absorbing_organisation:, merging_organisations:) }

    before do
      create(:organisation_relationship, child_organisation: absorbing_organisation, parent_organisation: stock_owner1)
      create(:organisation_relationship, child_organisation: merging_organisations.first, parent_organisation: stock_owner2)
      create(:organisation_relationship, child_organisation: merging_organisations.first, parent_organisation: stock_owner1)
      create(:organisation_relationship, child_organisation: merging_organisations.first, parent_organisation: stock_owner3)
      create(:organisation_relationship, parent_organisation: absorbing_organisation, child_organisation: managing_agent1)
      create(:organisation_relationship, parent_organisation: absorbing_organisation, child_organisation: managing_agent2)
      create(:organisation_relationship, parent_organisation: merging_organisations.first, child_organisation: managing_agent2)
    end

    describe "#total_stock_owners_after_merge" do
      it "returns the correct count of stock owners after merge" do
        expect(merge_request.total_stock_owners_after_merge).to eq(2)
      end
    end

    describe "#total_managing_agents_after_merge" do
      it "returns the correct count of managing agents after merge" do
        expect(merge_request.total_managing_agents_after_merge).to eq(1)
      end
    end

    describe "#total_stock_owners_managing_agents_label" do
      it "returns the correct label" do
        expect(merge_request.total_stock_owners_managing_agents_label).to eq("2 stock owners\n1 managing agent")
      end
    end
  end
end
