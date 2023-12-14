require "rails_helper"

describe FilterManager do
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
          searched_log = FactoryBot.create(:sales_log, purchid: "kzmgaiFNsx323")
          SalesLog.where(id: [searched_log.id] + logs.map(&:id))
        end

        context "when given a purchid" do
          let(:search_term) { "kzmgaiFNsx323" }

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

  describe "filter_schemes" do
    let(:schemes) { create_list(:scheme, 5) }
    let(:alphabetical_order_schemes) { [schemes[4], schemes[2], schemes[0], schemes[1], schemes[3]] }

    before do
      schemes[4].update!(service_name: "a")
      schemes[2].update!(service_name: "bB")
      schemes[0].update!(service_name: "C")
      schemes[1].update!(service_name: "Dd")
      schemes[3].update!(service_name: "e")
    end

    it "returns schemes in alphabetical order by service name" do
      expect(described_class.filter_schemes(Scheme.all, nil, {}, nil, nil)).to eq(alphabetical_order_schemes)
    end
  end
end
