require "rails_helper"
require "rake"

RSpec.describe "bulk_update" do
  def replace_entity_ids(scheme_1, scheme_2, scheme_3, _incomplete_scheme, export_template)
    export_template.sub!(/\{id1\}/, "S#{scheme_1.id}")
    export_template.sub!(/\{id2\}/, "S#{scheme_2.id}")
    export_template.sub!(/\{id3\}/, "S#{scheme_3.id}")
    # export_template.sub!(/\{id4\}/, "S#{incomplete_scheme.id}")
  end

  before do
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(Configuration::EnvConfigurationService).to receive(:new).and_return(env_config_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("CSV_DOWNLOAD_PAAS_INSTANCE").and_return(instance_name)

    WebMock.stub_request(:get, /api\.postcodes\.io/)
      .to_return(status: 200, body: "{\"status\":404,\"error\":\"Postcode not found\"}", headers: {})
    WebMock.stub_request(:get, /api\.postcodes\.io\/postcodes\/B11BB/)
      .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Westminster","codes":{"admin_district":"E08000035"}}}', headers: {})
  end

  describe ":update_schemes_from_csv", type: :task do
    subject(:task) { Rake::Task["bulk_update:update_schemes_from_csv"] }

    let(:instance_name) { "import_instance" }
    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:env_config_service) { instance_double(Configuration::EnvConfigurationService) }

    before do
      Rake.application.rake_require("tasks/update_schemes_and_locations_from_csv")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:original_schemes_csv_path) { "original_schemes.csv" }
      let(:updated_schemes_csv_path) { "updated_schemes.csv" }
      let(:wrong_file_path) { "/test/no_csv_here.csv" }
      let!(:different_organisation) { FactoryBot.create(:organisation, name: "Different organisation") }
      let(:schemes) do
        create_list(:scheme,
                    3,
                    service_name: "Test name",
                    sensitive: 1,
                    registered_under_care_act: 4,
                    support_type: 4,
                    scheme_type: 7,
                    arrangement_type: "D",
                    intended_stay: "M",
                    primary_client_group: "G",
                    secondary_client_group: "M",
                    has_other_client_group: 1,
                    owning_organisation: FactoryBot.create(:organisation),
                    confirmed: true,
                    created_at: Time.zone.local(2021, 4, 1),
                    total_units: 2)
      end

      let(:incomplete_scheme) do
        build(:scheme,
              service_name: "Incomplete scheme",
              sensitive: 1,
              registered_under_care_act: 4,
              support_type: nil,
              scheme_type: 7,
              arrangement_type: "D",
              intended_stay: nil,
              primary_client_group: "G",
              secondary_client_group: nil,
              has_other_client_group: nil,
              owning_organisation: FactoryBot.create(:organisation),
              created_at: Time.zone.local(2021, 4, 1),
              total_units: 2)
      end

      before do
        incomplete_scheme.save!(validate: false)
        allow(storage_service).to receive(:get_file_io)
        .with("original_schemes.csv")
        .and_return(StringIO.new(replace_entity_ids(schemes[0], schemes[1], schemes[2], incomplete_scheme, File.open("./spec/fixtures/files/original_schemes.csv").read)))

        allow(storage_service).to receive(:get_file_io)
        .with("updated_schemes.csv")
        .and_return(StringIO.new(replace_entity_ids(schemes[0], schemes[1], schemes[2], incomplete_scheme, File.open("./spec/fixtures/files/updated_schemes.csv").read)))
      end

      it "updates the allowed scheme fields if they have changed and doesn't update other fields" do
        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)
        schemes[0].reload
        expect(schemes[0].service_name).to eq("Updated test name")
        expect(schemes[0].sensitive).to eq("No")
        expect(schemes[0].registered_under_care_act).to eq("No")
        expect(schemes[0].support_type).to eq("Low level")
        expect(schemes[0].scheme_type).to eq("Direct Access Hostel")
        expect(schemes[0].arrangement_type).to eq("Another registered stock owner")
        expect(schemes[0].intended_stay).to eq("Permanent")
        expect(schemes[0].primary_client_group).to eq("People with drug problems")
        # expect(schemes[0].secondary_client_group).to eq(nil)
        expect(schemes[0].has_other_client_group).to eq("No")
        expect(schemes[0].owning_organisation).to eq(different_organisation)
        expect(schemes[0].created_at).to eq(Time.zone.local(2021, 4, 1))
        expect(schemes[0].total_units).to eq(2)
      end

      it "does not update the scheme if it hasn't changed" do
        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)
        schemes[1].reload
        expect(schemes[1].service_name).to eq("Test name")
        expect(schemes[1].sensitive).to eq("Yes")
        expect(schemes[1].registered_under_care_act).to eq("Yes – registered care home providing nursing care")
        expect(schemes[1].support_type).to eq("High level")
        expect(schemes[1].scheme_type).to eq("Housing for older people")
        expect(schemes[1].arrangement_type).to eq("The same organisation that owns the housing stock")
        expect(schemes[1].intended_stay).to eq("Medium stay")
        expect(schemes[1].primary_client_group).to eq("People with alcohol problems")
        expect(schemes[1].secondary_client_group).to eq("Older people with support needs")
        expect(schemes[1].has_other_client_group).to eq("Yes")
        expect(schemes[1].owning_organisation).not_to eq(different_organisation)
        expect(schemes[1].created_at).to eq(Time.zone.local(2021, 4, 1))
        expect(schemes[1].total_units).to eq(2)
      end

      it "does not update the scheme with invalid values" do
        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)
        schemes[2].reload
        expect(schemes[2].service_name).to eq("Test name")
        expect(schemes[2].sensitive).to eq("Yes")
        expect(schemes[2].registered_under_care_act).to eq("Yes – registered care home providing nursing care")
        expect(schemes[2].support_type).to eq("High level")
        expect(schemes[2].scheme_type).to eq("Housing for older people")
        expect(schemes[2].arrangement_type).to eq("The same organisation that owns the housing stock")
        expect(schemes[2].intended_stay).to eq("Medium stay")
        expect(schemes[2].primary_client_group).to eq("People with alcohol problems")
        expect(schemes[2].secondary_client_group).to eq("Older people with support needs")
        expect(schemes[2].has_other_client_group).to eq("Yes")
        expect(schemes[2].owning_organisation).not_to eq(different_organisation)
        expect(schemes[2].created_at).to eq(Time.zone.local(2021, 4, 1))
        expect(schemes[2].total_units).to eq(2)
      end

      it "logs the progress of the update" do
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with service_name: Updated test name")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with sensitive: No")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with scheme_type: Direct Access Hostel")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with arrangement_type: Another registered stock owner")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with primary_client_group: People with drug problems")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with has_other_client_group: No")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with support_type: Low level")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with intended_stay: Permanent")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with registered_under_care_act: No")
        # expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with secondary_client_group: nil")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id}, with owning_organisation: Different organisation")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[0].id} with status as it it not a permitted field")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[0].id} with created_at as it it not a permitted field")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[0].id} with active_dates as it it not a permitted field")

        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with sensitive: Yse. 'Yse' is not a valid sensitive")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with scheme_type: Direct access Hostel. 'Direct access Hostel' is not a valid scheme_type")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with owning_organisation_name: non existing org. Organisation with name non existing org is not in the database")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with arrangement_type: wrong answer. 'wrong answer' is not a valid arrangement_type")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with primary_client_group: FD. 'FD' is not a valid primary_client_group")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with has_other_client_group: no. 'no' is not a valid has_other_client_group")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with secondary_client_group: lder people with support needs. 'lder people with support needs' is not a valid secondary_client_group")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with support_type: high. 'high' is not a valid support_type")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with intended_stay: Permanent . 'Permanent ' is not a valid intended_stay")

        expect(Rails.logger).to receive(:info).with("Scheme with id Wrong_id is not in the original scheme csv")
        expect(Rails.logger).to receive(:info).with("Scheme with id SWrong_id is not in the database")

        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)
      end

      it "raises an error when no paths are given" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake bulk_update:update_schemes_from_csv['original_file_name','updated_file_name']")
      end

      it "raises an error when no original path is given" do
        expect { task.invoke(nil, updated_schemes_csv_path) }.to raise_error(RuntimeError, "Usage: rake bulk_update:update_schemes_from_csv['original_file_name','updated_file_name']")
      end

      it "raises an error when no updated path is given" do
        expect { task.invoke(original_schemes_csv_path, nil) }.to raise_error(RuntimeError, "Usage: rake bulk_update:update_schemes_from_csv['original_file_name','updated_file_name']")
      end
    end
  end
end
