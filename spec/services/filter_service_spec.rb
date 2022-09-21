require "rails_helper"

describe FilterService do
  describe "filter_by_search" do
    before do
      FactoryBot.create_list(:organisation, 5)
      FactoryBot.create(:organisation, name: "Acme LTD")
    end

    let(:organisation_list) { Organisation.all }

    context "when given a search term" do
      let(:search_term) { "Acme" }

      it "filters the collection on search term" do
        expect(described_class.filter_by_search(organisation_list, search_term).count).to eq(1)
      end
    end

    context "when not given a search term" do
      let(:search_term) { nil }

      it "does not filter the given collection" do
        expect(described_class.filter_by_search(organisation_list, search_term).count).to eq(6)
      end
    end
  end
end
