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

  describe "filter_users" do
    let(:data_provider_user) { FactoryBot.create(:user, role: "data_provider") }
    let(:data_coordinator_user) { FactoryBot.create(:user, role: "data_coordinator") }
    let(:support_user) { FactoryBot.create(:user, role: "support") }
    let(:key_contact_user) { FactoryBot.create(:user, is_key_contact: true) }
    let(:dpo_user) { FactoryBot.create(:user, is_dpo: true) }
    let(:key_contact_dpo_user) { FactoryBot.create(:user, is_key_contact: true, is_dpo: true) }

    context "when filtering by role" do
      it "returns users with the role" do
        filter = { "role" => %w[data_provider] }
        result = described_class.filter_users(User.all, nil, filter, nil)
        expect(result).to include(data_provider_user)
        expect(result).not_to include(data_coordinator_user)
        expect(result).not_to include(support_user)
      end

      it "returns users with multiple roles selected" do
        filter = { "role" => %w[data_provider data_coordinator] }
        result = described_class.filter_users(User.all, nil, filter, nil)
        expect(result).to include(data_provider_user)
        expect(result).to include(data_coordinator_user)
        expect(result).not_to include(support_user)
      end
    end

    context "when filtering by additional responsibilities" do
      it "returns users with the additional responsibilities" do
        filter = { "additional_responsibilities" => %w[data_protection_officer] }
        result = described_class.filter_users(User.all, nil, filter, nil)
        expect(result).to include(dpo_user)
        expect(result).to include(key_contact_dpo_user)
        expect(result).not_to include(key_contact_user)
        expect(result).not_to include(support_user)
      end

      it "returns users with multiple additional responsibilities selected" do
        filter = { "additional_responsibilities" => %w[data_protection_officer key_contact] }
        result = described_class.filter_users(User.all, nil, filter, nil)
        expect(result).to include(dpo_user)
        expect(result).to include(key_contact_dpo_user)
        expect(result).to include(key_contact_user)
        expect(result).not_to include(support_user)
      end
    end
  end
end
