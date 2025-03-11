require "rails_helper"

RSpec.describe AddressSearchController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "#manual input" do
    context "when no address data is given and user chooses to enter address manually" do
      let(:sales_log) { create(:sales_log, :shared_ownership_setup_complete, manual_address_entry_selected: false, assigned_to: user) }

      it "correctly sets address fields" do
        sales_log.reload
        expect(sales_log.manual_address_entry_selected).to eq(false)
        expect(sales_log.uprn_known).to eq(nil)
        expect(sales_log.uprn).to eq(nil)
        expect(sales_log.uprn_confirmed).to eq(nil)
        expect(sales_log.uprn_selection).to eq(nil)
        expect(sales_log.pcodenk).to eq(nil)
        expect(sales_log.postcode_full).to eq(nil)
        expect(sales_log.address_line1).to eq(nil)
        expect(sales_log.address_line2).to eq(nil)
        expect(sales_log.town_or_city).to eq(nil)
        expect(sales_log.la).to eq(nil)

        get "/address-search/manual-input/sales_log/#{sales_log.id}"

        sales_log.reload
        expect(sales_log.manual_address_entry_selected).to eq(true)
        expect(sales_log.uprn_known).to eq(0)
        expect(sales_log.uprn).to eq(nil)
        expect(sales_log.uprn_confirmed).to eq(nil)
        expect(sales_log.uprn_selection).to eq(nil)
        expect(sales_log.pcodenk).to eq(nil)
        expect(sales_log.postcode_full).to eq(nil)
        expect(sales_log.address_line1).to eq(nil)
        expect(sales_log.address_line2).to eq(nil)
        expect(sales_log.town_or_city).to eq(nil)
        expect(sales_log.la).to eq(nil)
      end
    end

    context "when choosing to manually input an address for a log that has an address searched value" do
      let(:lettings_log) { create(:lettings_log, :completed, manual_address_entry_selected: false, assigned_to: user) }

      it "correctly sets address fields" do
        lettings_log.reload
        expect(lettings_log.uprn_known).to eq(1)
        expect(lettings_log.uprn).to eq("10033558653")
        expect(lettings_log.uprn_confirmed).to eq(1)
        expect(lettings_log.uprn_selection).to eq("10033558653")
        expect(lettings_log.postcode_known).to eq(1)
        expect(lettings_log.postcode_full).to eq("SW1A 1AA")
        expect(lettings_log.address_line1).to eq("The Mall, City Of Westminster")
        expect(lettings_log.address_line2).to eq(nil)
        expect(lettings_log.town_or_city).to eq("London")
        expect(lettings_log.la).to eq("E09000033")

        get "/address-search/manual-input/lettings_log/#{lettings_log.id}"

        lettings_log.reload
        expect(lettings_log.manual_address_entry_selected).to eq(true)
        expect(lettings_log.uprn_known).to eq(0)
        expect(lettings_log.uprn).to eq(nil)
        expect(lettings_log.uprn_confirmed).to eq(nil)
        expect(lettings_log.uprn_selection).to eq(nil)
        expect(lettings_log.postcode_known).to eq(nil)
        expect(lettings_log.postcode_full).to eq(nil)
        expect(lettings_log.address_line1).to eq(nil)
        expect(lettings_log.address_line2).to eq(nil)
        expect(lettings_log.town_or_city).to eq(nil)
        expect(lettings_log.la).to eq(nil)
      end
    end
  end

  describe "#search input" do
    context "when no address is entered manually and choosing to search instead" do
      let(:lettings_log) { create(:lettings_log, :setup_completed, manual_address_entry_selected: true, assigned_to: user) }

      it "correctly sets address fields" do
        lettings_log.reload
        expect(lettings_log.manual_address_entry_selected).to eq(true)
        expect(lettings_log.uprn_known).to eq(0)
        expect(lettings_log.uprn).to eq(nil)
        expect(lettings_log.uprn_confirmed).to eq(nil)
        expect(lettings_log.uprn_selection).to eq(nil)
        expect(lettings_log.postcode_known).to eq(nil)
        expect(lettings_log.postcode_full).to eq(nil)
        expect(lettings_log.address_line1).to eq(nil)
        expect(lettings_log.address_line2).to eq(nil)
        expect(lettings_log.town_or_city).to eq(nil)
        expect(lettings_log.la).to eq(nil)

        get "/address-search/search-input/lettings_log/#{lettings_log.id}"

        lettings_log.reload
        expect(lettings_log.manual_address_entry_selected).to eq(false)
        expect(lettings_log.uprn_known).to eq(nil)
        expect(lettings_log.uprn).to eq(nil)
        expect(lettings_log.uprn_confirmed).to eq(nil)
        expect(lettings_log.uprn_selection).to eq(nil)
        expect(lettings_log.postcode_known).to eq(nil)
        expect(lettings_log.postcode_full).to eq(nil)
        expect(lettings_log.address_line1).to eq(nil)
        expect(lettings_log.address_line2).to eq(nil)
        expect(lettings_log.town_or_city).to eq(nil)
        expect(lettings_log.la).to eq(nil)
      end
    end

    context "when choosing to search for an address for a log that has an address searched value" do
      let(:sales_log) { create(:sales_log, :completed, manual_address_entry_selected: true, town_or_city: "Test Town", assigned_to: user) }

      it "correctly sets address fields" do
        sales_log.reload
        expect(sales_log.manual_address_entry_selected).to eq(true)
        expect(sales_log.uprn_known).to eq(0)
        expect(sales_log.uprn).to eq(nil)
        expect(sales_log.uprn_confirmed).to eq(nil)
        expect(sales_log.uprn_selection).to eq(nil)
        expect(sales_log.pcodenk).to eq(0)
        expect(sales_log.postcode_full).to eq("SW1A 1AA")
        expect(sales_log.address_line1).to eq("Address line 1")
        expect(sales_log.address_line2).to eq(nil)
        expect(sales_log.town_or_city).to eq("Test Town")
        expect(sales_log.la).to eq("E09000033")

        get "/address-search/search-input/sales_log/#{sales_log.id}"

        sales_log.reload
        expect(sales_log.manual_address_entry_selected).to eq(false)
        expect(sales_log.uprn_known).to eq(nil)
        expect(sales_log.uprn).to eq(nil)
        expect(sales_log.uprn_confirmed).to eq(nil)
        expect(sales_log.uprn_selection).to eq(nil)
        expect(sales_log.pcodenk).to eq(nil)
        expect(sales_log.postcode_full).to eq(nil)
        expect(sales_log.address_line1).to eq(nil)
        expect(sales_log.address_line2).to eq(nil)
        expect(sales_log.town_or_city).to eq(nil)
        expect(sales_log.la).to eq(nil)
      end
    end

    context "when searching by address and UPRN" do
      let(:sales_log) { create(:sales_log, :completed, manual_address_entry_selected: false, assigned_to: user) }

      context "and theres no uprn returned" do
        before do
          body = { results: [{ DPA: { "ADDRESS": "1, Test Street", "UPRN": "123" } }] }.to_json
          uprn_body = { results: [{ DPA: nil }] }.to_json
          WebMock.stub_request(:get, "https://api.os.uk/search/places/v1/find?key=OS_DATA_KEY&maxresults=10&minmatch=0.2&query=100")
                 .to_return(status: 200, body:, headers: {})
          WebMock.stub_request(:get, "https://api.os.uk/search/places/v1/uprn?dataset=DPA,LPI&key=OS_DATA_KEY&uprn=100")
                 .to_return(status: 200, body: uprn_body, headers: {})
        end

        it "returns the address results" do
          get "/address-search?query=100"

          expect(response).to have_http_status(:ok)
          expect(response.body).to eq([{ text: "1, Test Street", value: "123" }].to_json)
        end
      end

      context "and theres no address returned" do
        before do
          body = { results: [{ DPA: nil }] }.to_json
          uprn_body = { results: [{ DPA: { "ADDRESS": "2, Test Street", UPRN: "321" } }] }.to_json
          WebMock.stub_request(:get, "https://api.os.uk/search/places/v1/find?key=OS_DATA_KEY&maxresults=10&minmatch=0.2&query=100")
                 .to_return(status: 200, body:, headers: {})
          WebMock.stub_request(:get, "https://api.os.uk/search/places/v1/uprn?dataset=DPA,LPI&key=OS_DATA_KEY&uprn=100")
                 .to_return(status: 200, body: uprn_body, headers: {})
        end

        it "returns the address results" do
          get "/address-search?query=100"

          expect(response).to have_http_status(:ok)
          expect(response.body).to eq([{ text: "2, Test Street", value: "321" }].to_json)
        end
      end
    end
  end
end
