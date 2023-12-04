require "rails_helper"

RSpec.describe Csv::MissingAddressesCsvService do
  let(:organisation) { create(:organisation, name: "Address org") }
  let(:user) { create(:user, organisation:, email: "testy@example.com") }
  let(:service) { described_class.new(organisation, skip_uprn_issue_organisations) }
  let(:skip_uprn_issue_organisations) { [100, 200] }

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

  around do |example|
    Timecop.freeze(Time.zone.local(2023, 4, 5)) do
      Singleton.__init__(FormHandler)
      example.run
    end
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

      context "and the organisation is marked as an organisation to skip" do
        let(:skip_uprn_issue_organisations) { [organisation.id] }

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
        lettings_log.startdate = Time.zone.local(2022, 4, 5)
        lettings_log.save!(validate: false)
        lettings_log_missing_town.startdate = Time.zone.local(2022, 4, 5)
        lettings_log_missing_town.save!(validate: false)
        lettings_log_wrong_uprn.startdate = Time.zone.local(2022, 4, 5)
        lettings_log_wrong_uprn.save!(validate: false)
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

      context "and the organisation is marked as an organisation to skip" do
        let(:skip_uprn_issue_organisations) { [organisation.id] }

        it "returns nil" do
          expect(service.create_missing_sales_addresses_csv).to be_nil
        end
      end
    end

    context "when the organisation only has logs with missing addresses from 2022" do
      before do
        sales_log.saledate = Time.zone.local(2022, 4, 5)
        sales_log.save!(validate: false)
        sales_log_missing_town.saledate = Time.zone.local(2022, 4, 5)
        sales_log_missing_town.save!(validate: false)
        sales_log_wrong_uprn.saledate = Time.zone.local(2022, 4, 5)
        sales_log_wrong_uprn.save!(validate: false)
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

  describe "#create_lettings_addresses_csv" do
    context "when the organisation has lettings logs" do
      let!(:lettings_log) do
        create(:lettings_log,
               tenancycode: "tenancycode1",
               propcode: "propcode1",
               startdate: Time.zone.local(2023, 4, 5),
               created_by: user,
               owning_organisation: organisation,
               managing_organisation: organisation,
               address_line1: "address",
               town_or_city: "town",
               old_id: "old_id_1",
               old_form_id: "old_form_id_1",
               needstype: 1,
               uprn_known: 0)
      end

      let!(:lettings_log_missing_address) do
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

      let!(:lettings_log_not_imported) do
        create(:lettings_log,
               tenancycode: "tenancycode",
               propcode: "propcode",
               startdate: Time.zone.local(2023, 4, 5),
               created_by: user,
               owning_organisation: organisation,
               managing_organisation: organisation,
               uprn: "123",
               uprn_known: 1,
               needstype: 1)
      end

      before do
        lettings_log = create(:lettings_log, managing_organisation: organisation, old_id: "exists")
        lettings_log.startdate = Time.zone.local(2022, 4, 5)
        lettings_log.save!(validate: false)
      end

      it "returns a csv with relevant logs" do
        csv = CSV.parse(service.create_lettings_addresses_csv)
        expect(csv.count).to eq(6)
        expect(csv).to include([lettings_log.id.to_s, "2023-04-05", "tenancycode1", "propcode1", "testy@example.com", "Address org", "Address org", nil, "address", nil, "town", nil, nil])
        expect(csv).to include([lettings_log_missing_address.id.to_s, "2023-04-05", "tenancycode", "propcode", "testy@example.com", "Address org", "Address org", nil, nil, nil, nil, nil, nil])
        expect(csv).to include([lettings_log_missing_town.id.to_s, "2023-04-05", "tenancycode", "propcode", "testy@example.com", "Address org", "Address org", nil, "existing address", nil, nil, nil, nil])
        expect(csv).to include([lettings_log_wrong_uprn.id.to_s, "2023-04-05", "tenancycode", "propcode", "testy@example.com", "Address org", "Address org", "123", "Some Place", nil, "Bristol", nil, "BS1 1AD"])
        expect(csv).to include([lettings_log_not_imported.id.to_s, "2023-04-05", "tenancycode", "propcode", "testy@example.com", "Address org", "Address org", "123", "Some Place", nil, "Bristol", nil, "BS1 1AD"])
      end
    end

    context "when the organisation does not have relevant lettings logs" do
      before do
        lettings_log = create(:lettings_log, managing_organisation: organisation)
        lettings_log.startdate = Time.zone.local(2022, 4, 5)
        lettings_log.save!(validate: false)
      end

      it "returns only headers" do
        csv = service.create_lettings_addresses_csv
        expect(csv).to eq "Log ID,Tenancy start date,Tenant code,Property reference,Log owner,Owning organisation,Managing organisation,UPRN,Address Line 1,Address Line 2 (optional),Town or City,County (optional),Property's postcode\n"
      end
    end
  end

  describe "#create_sales_addresses_csv" do
    context "when the organisation has sales" do
      let!(:sales_log) do
        create(:sales_log,
               purchid: "purchaser code",
               saledate: Time.zone.local(2023, 4, 5),
               created_by: user,
               owning_organisation: organisation,
               address_line1: "address",
               town_or_city: "city",
               old_id: "old_id_1",
               old_form_id: "old_form_id_1",
               uprn_known: 0)
      end

      let!(:sales_log_missing_address) do
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

      let!(:sales_log_not_imported) do
        create(:sales_log,
               :completed,
               purchid: "purchaser code",
               saledate: Time.zone.local(2023, 4, 5),
               created_by: user,
               owning_organisation: organisation,
               uprn: "123",
               town_or_city: "Bristol",
               uprn_known: 1,
               uprn_confirmed: 1,
               la: nil)
      end

      before do
        sales_log = create(:sales_log, :completed)
        sales_log.saledate = Time.zone.local(2022, 4, 5)
        sales_log.save!(validate: false)
      end

      it "returns a csv with relevant logs" do
        csv = CSV.parse(service.create_sales_addresses_csv)
        expect(csv.count).to eq(6)
        expect(csv).to include([sales_log.id.to_s, "2023-04-05", "purchaser code", "testy@example.com", "Address org", nil, "address", nil, "city", nil, nil])
        expect(csv).to include([sales_log_missing_address.id.to_s, "2023-04-05", "purchaser code", "testy@example.com", "Address org", nil, nil, nil, nil, nil, nil])
        expect(csv).to include([sales_log_missing_town.id.to_s, "2023-04-05", "purchaser code", "testy@example.com", "Address org", nil, "existing address line 1", nil, nil, nil, nil])
        expect(csv).to include([sales_log_wrong_uprn.id.to_s, "2023-04-05", "purchaser code", "testy@example.com", "Address org", "123", "Some Place", nil, "Bristol", nil, "BS1 1AD"])
        expect(csv).to include([sales_log_not_imported.id.to_s, "2023-04-05", "purchaser code", "testy@example.com", "Address org", "123", "Some Place", nil, "Bristol", nil, "BS1 1AD"])
      end
    end

    context "when the organisation does not have relevant sales logs" do
      before do
        sales_log = create(:sales_log, :completed)
        sales_log.saledate = Time.zone.local(2022, 4, 5)
        sales_log.save!(validate: false)
      end

      it "returns only headers" do
        csv = service.create_sales_addresses_csv
        expect(csv).to eq("Log ID,Sale completion date,Purchaser code,Log owner,Owning organisation,UPRN,Address Line 1,Address Line 2 (optional),Town or City,County (optional),Property's postcode\n")
      end
    end
  end
end
