require "rails_helper"

RSpec.describe Csv::MissingAddressesCsvService do
  let(:organisation) { create(:organisation, name: "Address org") }
  let(:user) { create(:user, organisation:, email: "testy@example.com") }
  let(:service) { described_class.new(organisation) }

  before do
    body_1 = {
      results: [
        {
          DPA: {
            "POSTCODE": "BS1 1AD",
            "POST_TOWN": "Bristol",
            "ORGANISATION_NAME": "Some place",
          },
        },
      ],
    }.to_json

    body_2 = {
      results: [
        {
          DPA: {
            "POSTCODE": "EC1N 2TD",
            "POST_TOWN": "Newcastle",
            "ORGANISATION_NAME": "Some place",
          },
        },
      ],
    }.to_json

    stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=123")
    .to_return(status: 200, body: body_1, headers: {})

    stub_request(:get, "https://api.os.uk/search/places/v1/uprn?key=OS_DATA_KEY&uprn=12")
    .to_return(status: 200, body: body_2, headers: {})
  end

  def replace_entity_ids(lettings_log, export_template)
    export_template.sub!(/\{id\}/, lettings_log.id.to_s)
  end

  describe "#create_missing_lettings_addresses_csv" do
    let!(:lettings_log) do
      create(:lettings_log,
             tenancycode: "tenancycode",
             propcode: "propcode",
             startdate: Time.zone.local(2023, 4, 5),
             created_by: user,
             owning_organisation: organisation,
             managing_organisation: organisation,
             address_line1: nil,
             town_or_city: nil,
             old_id: "old_id",
             old_form_id: "old_form_id",
             needstype: 1,
             uprn_known: 0)
    end

    let!(:lettings_log_missing_town) do
      create(:lettings_log,
             tenancycode: "tenancycode",
             propcode: "propcode",
             startdate: Time.zone.local(2023, 4, 5),
             created_by: user,
             owning_organisation: organisation,
             managing_organisation: organisation,
             address_line1: "existing address",
             town_or_city: nil,
             old_id: "older_id",
             old_form_id: "old_form_id",
             needstype: 1,
             uprn_known: 0)
    end

    let!(:lettings_log_wrong_uprn) do
      create(:lettings_log,
             tenancycode: "tenancycode",
             propcode: "propcode",
             startdate: Time.zone.local(2023, 4, 5),
             created_by: user,
             owning_organisation: organisation,
             managing_organisation: organisation,
             uprn: "123",
             uprn_known: 1,
             old_id: "oldest_id",
             needstype: 1)
    end

    context "when the organisation has logs with missing addresses, missing town or city and wrong uprn" do
      it "returns a csv with relevant logs" do
        expected_content = replace_entity_ids(lettings_log, File.open("spec/fixtures/files/missing_lettings_logs_addresses_all_issues.csv").read)
        expected_content = replace_entity_ids(lettings_log_missing_town, expected_content)
        expected_content = replace_entity_ids(lettings_log_wrong_uprn, expected_content)
        csv = service.create_missing_lettings_addresses_csv
        expect(csv).to eq(expected_content)
      end
    end

    context "when the organisation has logs with missing addresses only" do
      before do
        lettings_log_missing_town.update!(town_or_city: "towncity")
        lettings_log_wrong_uprn.update!(uprn: "12")
      end

      it "returns a csv with relevant logs" do
        expected_content = replace_entity_ids(lettings_log, File.open("spec/fixtures/files/missing_lettings_logs_addresses.csv").read)
        csv = service.create_missing_lettings_addresses_csv
        expect(csv).to eq(expected_content)
      end
    end

    context "when the organisation has logs with missing town or city only" do
      before do
        lettings_log.update!(address_line1: "existing address", town_or_city: "towncity")
        lettings_log_wrong_uprn.update!(uprn: "12")
      end

      it "returns a csv with relevant logs" do
        expected_content = replace_entity_ids(lettings_log_missing_town, File.open("spec/fixtures/files/missing_lettings_logs_town_or_city.csv").read)
        csv = service.create_missing_lettings_addresses_csv
        expect(csv).to eq(expected_content)
      end
    end

    context "when the organisation has logs with wrong uprn only" do
      before do
        lettings_log.update!(address_line1: "existing address", town_or_city: "towncity")
        lettings_log_missing_town.update!(town_or_city: "towncity")
        lettings_log_wrong_uprn.update!(uprn: "12", propcode: "12")
      end

      it "returns a csv with relevant logs" do
        expected_content = replace_entity_ids(lettings_log_wrong_uprn, File.open("spec/fixtures/files/missing_lettings_logs_wrong_uprn.csv").read)
        csv = service.create_missing_lettings_addresses_csv
        expect(csv).to eq(expected_content)
      end

      context "and the organisation is in the SKIP_UPRN_ISSUE_ORG_IDS list" do
        before do
          allow(ENV).to receive(:[]).with("SKIP_UPRN_ISSUE_ORG_IDS").and_return([organisation.id].to_json)
        end

        it "returns nil" do
          expect(service.create_missing_lettings_addresses_csv).to be_nil
        end
      end
    end

    context "when the organisation only has supported housing logs with missing addresses or town or city" do
      before do
        lettings_log.update!(needstype: 2)
        lettings_log_missing_town.update!(needstype: 2)
        lettings_log_wrong_uprn.update!(needstype: 2)
      end

      it "returns nil" do
        expect(service.create_missing_lettings_addresses_csv).to be_nil
      end
    end

    context "when the organisation only has logs with missing addresses or town or city from 2022" do
      before do
        lettings_log.update!(startdate: Time.zone.local(2022, 4, 5))
        lettings_log_missing_town.update!(startdate: Time.zone.local(2022, 4, 5))
        lettings_log_wrong_uprn.update!(startdate: Time.zone.local(2022, 4, 5))
      end

      it "returns nil" do
        expect(service.create_missing_lettings_addresses_csv).to be_nil
      end
    end

    context "when the organisation has any address and town or city fields filled in or correct uprn" do
      before do
        lettings_log.update!(address_line1: "address_line1", town_or_city: "towncity")
        lettings_log_missing_town.update!(address_line1: "address_line1", town_or_city: "towncity")
        lettings_log_wrong_uprn.update!(uprn: "12")
      end

      it "returns nil" do
        expect(service.create_missing_lettings_addresses_csv).to be_nil
      end
    end
  end

  describe "#create_missing_sales_addresses_csv" do
    let!(:sales_log) do
      create(:sales_log,
             purchid: "purchaser code",
             saledate: Time.zone.local(2023, 4, 5),
             created_by: user,
             owning_organisation: organisation,
             address_line1: nil,
             town_or_city: nil,
             old_id: "old_id",
             old_form_id: "old_form_id",
             uprn_known: 0)
    end

    let!(:sales_log_missing_town) do
      create(:sales_log,
             purchid: "purchaser code",
             saledate: Time.zone.local(2023, 4, 5),
             created_by: user,
             owning_organisation: organisation,
             address_line1: "existing address line 1",
             town_or_city: nil,
             old_id: "older_id",
             old_form_id: "old_form_id",
             uprn_known: 0)
    end

    let!(:sales_log_wrong_uprn) do
      create(:sales_log,
             :completed,
             purchid: "purchaser code",
             saledate: Time.zone.local(2023, 4, 5),
             created_by: user,
             owning_organisation: organisation,
             uprn: "123",
             town_or_city: "Bristol",
             old_id: "oldest_id",
             uprn_known: 1,
             uprn_confirmed: 1,
             la: nil)
    end

    context "when the organisation has logs with missing addresses, town or city and wrong uprn" do
      it "returns a csv with relevant logs" do
        expected_content = replace_entity_ids(sales_log, File.open("spec/fixtures/files/missing_sales_logs_addresses_all_issues.csv").read)
        expected_content = replace_entity_ids(sales_log_missing_town, expected_content)
        expected_content = replace_entity_ids(sales_log_wrong_uprn, expected_content)
        csv = service.create_missing_sales_addresses_csv
        expect(csv).to eq(expected_content)
      end
    end

    context "when the organisation has logs with missing addresses" do
      before do
        sales_log_missing_town.update!(town_or_city: "towncity")
        sales_log_wrong_uprn.update!(uprn: "12")
      end

      it "returns a csv with relevant logs" do
        expected_content = replace_entity_ids(sales_log, File.open("spec/fixtures/files/missing_sales_logs_addresses.csv").read)
        csv = service.create_missing_sales_addresses_csv
        expect(csv).to eq(expected_content)
      end
    end

    context "when the organisation has logs with missing town_or_city only" do
      before do
        sales_log.update!(address_line1: "address", town_or_city: "towncity")
        sales_log_wrong_uprn.update!(uprn: "12")
      end

      it "returns a csv with relevant logs" do
        expected_content = replace_entity_ids(sales_log_missing_town, File.open("spec/fixtures/files/missing_sales_logs_town_or_city.csv").read)
        csv = service.create_missing_sales_addresses_csv
        expect(csv).to eq(expected_content)
      end
    end

    context "when the organisation has logs with wrong uprn only" do
      before do
        sales_log.update!(address_line1: "address", town_or_city: "towncity")
        sales_log_missing_town.update!(town_or_city: "towncity")
        sales_log_wrong_uprn.update!(uprn: "12", purchid: "12")
      end

      it "returns a csv with relevant logs" do
        expected_content = replace_entity_ids(sales_log_wrong_uprn, File.open("spec/fixtures/files/missing_sales_logs_wrong_uprn.csv").read)
        csv = service.create_missing_sales_addresses_csv
        expect(csv).to eq(expected_content)
      end

      context "and the organisation is in the SKIP_UPRN_ISSUE_ORG_IDS list" do
        before do
          allow(ENV).to receive(:[]).with("SKIP_UPRN_ISSUE_ORG_IDS").and_return([organisation.id].to_json)
        end

        it "returns nil" do
          expect(service.create_missing_sales_addresses_csv).to be_nil
        end
      end
    end

    context "when the organisation only has logs with missing addresses from 2022" do
      before do
        sales_log.update!(saledate: Time.zone.local(2022, 4, 5))
        sales_log_missing_town.update!(saledate: Time.zone.local(2022, 4, 5))
        sales_log_wrong_uprn.update!(saledate: Time.zone.local(2022, 4, 5))
      end

      it "returns nil" do
        expect(service.create_missing_sales_addresses_csv).to be_nil
      end
    end

    context "when the organisation has address fields filled in" do
      before do
        sales_log.update!(town_or_city: "town", address_line1: "line1")
        sales_log_missing_town.update!(town_or_city: "town")
        sales_log_wrong_uprn.update!(uprn: "12")
      end

      it "returns nil" do
        expect(service.create_missing_sales_addresses_csv).to be_nil
      end
    end
  end
end
