require "rails_helper"

describe FilterService do
  describe "filter_by_search" do
    context "when filtering organisations" do
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

    context "when filtering logs" do
      context "when filtering lettings logs" do
        let(:lettings_log_list) do
          logs = FactoryBot.create_list(:lettings_log, 5)
          searched_log = FactoryBot.create(:lettings_log, postcode_full: "SW1 1AA")
          LettingsLog.where(id: [searched_log.id] + logs.map(&:id))
        end

        context "when given a postcode" do
          let(:search_term) { "SW1 1AA" }

          it "filters the collection on search term" do
            expect(described_class.filter_by_search(lettings_log_list, search_term).count).to eq(1)
          end
        end

        context "when not given a search term" do
          let(:search_term) { nil }

          it "does not filter the given collection" do
            expect(described_class.filter_by_search(lettings_log_list, search_term).count).to eq(6)
          end
        end
      end

      context "when filtering sales logs" do
        let(:sales_log_list) do
          logs = FactoryBot.create_list(:sales_log, 5)
          searched_log = FactoryBot.create(:sales_log, purchid: "2")
          SalesLog.where(id: [searched_log.id] + logs.map(&:id))
        end

        context "when given a purchid" do
          let(:search_term) { "2" }

          it "filters the collection on search term" do
            expect(described_class.filter_by_search(sales_log_list, search_term).count).to eq(1)
          end
        end

        context "when not given a search term" do
          let(:search_term) { nil }

          it "does not filter the given collection" do
            expect(described_class.filter_by_search(sales_log_list, search_term).count).to eq(6)
          end
        end
      end
    end
  end
end
