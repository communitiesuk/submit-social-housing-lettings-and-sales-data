require "rails_helper"
require "rake"

RSpec.describe "bulk_update" do
  def replace_entity_ids(scheme_1, scheme_2, scheme_3, export_template)
    export_template.sub!(/\{id1\}/, "S#{scheme_1.id}")
    export_template.sub!(/\{id2\}/, "S#{scheme_2.id}")
    export_template.sub!(/\{id3\}/, "S#{scheme_3.id}")
  end

  def replace_entity_ids_for_locations(location_1, location_2, location_3, scheme_1, scheme_2, scheme_3, export_template)
    export_template.sub!(/\{id1\}/, location_1.id.to_s)
    export_template.sub!(/\{id2\}/, location_2.id.to_s)
    export_template.sub!(/\{id3\}/, location_3.id.to_s)
    export_template.sub!(/\{scheme_id1\}/, "S#{scheme_1['id']}")
    export_template.sub!(/\{scheme_id2\}/, "S#{scheme_2['id']}")
    export_template.sub!(/\{scheme_id3\}/, "S#{scheme_3['id']}")
  end

  before do
    Timecop.freeze(Time.zone.local(2024, 3, 1))
    allow(Storage::S3Service).to receive(:new).and_return(storage_service)
    allow(Configuration::EnvConfigurationService).to receive(:new).and_return(env_config_service)
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with("BULK_UPLOAD_BUCKET").and_return(instance_name)

    WebMock.stub_request(:get, /api\.postcodes\.io/)
      .to_return(status: 404, body: "{\"status\":404,\"error\":\"Postcode not found\"}", headers: {})
    WebMock.stub_request(:get, /api\.postcodes\.io\/postcodes\/B11BB/)
      .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Westminster","codes":{"admin_district":"E09000033"}}}', headers: {})
  end

  after do
    Timecop.return
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
                    registered_under_care_act: 5,
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
      let(:location) { FactoryBot.create(:location, scheme: schemes[0]) }
      let(:location_2) { FactoryBot.create(:location, scheme: schemes[1]) }
      let(:location_3) { FactoryBot.create(:location, scheme: schemes[2]) }
      let!(:lettings_log) { FactoryBot.create(:lettings_log, :sh, scheme: schemes[0], location:, values_updated_at: nil, owning_organisation: schemes[0].owning_organisation) }
      let!(:lettings_log_2) { FactoryBot.create(:lettings_log, :sh, scheme: schemes[1], location: location_2, values_updated_at: nil, owning_organisation: schemes[1].owning_organisation) }
      let!(:lettings_log_3) { FactoryBot.create(:lettings_log, :sh, scheme: schemes[2], location: location_3, values_updated_at: nil, owning_organisation: schemes[2].owning_organisation) }
      let!(:lettings_log_4) { FactoryBot.create(:lettings_log, :sh, scheme: schemes[0], location:, values_updated_at: nil, owning_organisation: schemes[0].owning_organisation) }
      let!(:lettings_log_5) { FactoryBot.create(:lettings_log, :sh, scheme: schemes[0], location:, values_updated_at: nil, owning_organisation: schemes[0].owning_organisation) }

      before do
        allow(storage_service).to receive(:get_file_io)
        .with("original_schemes.csv")
        .and_return(StringIO.new(replace_entity_ids(schemes[0], schemes[1], schemes[2], File.open("./spec/fixtures/files/original_schemes.csv").read)))

        allow(storage_service).to receive(:get_file_io)
        .with("updated_schemes.csv")
        .and_return(StringIO.new(replace_entity_ids(schemes[0], schemes[1], schemes[2], File.open("./spec/fixtures/files/updated_schemes.csv").read)))
      end

      it "updates the allowed scheme fields if they have changed and doesn't update other fields" do
        create(:organisation_relationship, parent_organisation: schemes[0].owning_organisation, child_organisation: different_organisation)

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
        expect(schemes[0].has_other_client_group).to eq("No")
        expect(schemes[0].owning_organisation).to eq(different_organisation)
        expect(schemes[0].created_at).to eq(Time.zone.local(2021, 4, 1))
        expect(schemes[0].total_units).to eq(2)
      end

      it "updates the lettings log if scheme has changed owning organisation" do
        create(:organisation_relationship, parent_organisation: schemes[0].owning_organisation, child_organisation: different_organisation)

        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)

        lettings_log.reload
        expect(lettings_log.scheme).to be_nil
        expect(lettings_log.location).to be_nil
      end

      it "does not update the scheme if it hasn't changed" do
        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)
        schemes[1].reload
        expect(schemes[1].service_name).to eq("Test name")
        expect(schemes[1].sensitive).to eq("Yes")
        expect(schemes[1].registered_under_care_act).to eq("Yes")
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
        expect(schemes[2].registered_under_care_act).to eq("Yes")
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

      it "does not update the owning organisation if the new organisation is not related to current organisation" do
        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)
        schemes[0].reload
        expect(schemes[0].owning_organisation).not_to eq(different_organisation)
      end

      it "does not update the owning organisation if there are logs from closed collection periods" do
        create(:organisation_relationship, parent_organisation: schemes[0].owning_organisation, child_organisation: different_organisation)
        lettings_log_4.startdate = Time.zone.local(2022, 4, 1)
        lettings_log_4.save!(validate: false)
        lettings_log_5.startdate = Time.zone.local(2021, 4, 1)
        lettings_log_5.save!(validate: false)
        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)

        schemes[0].reload
        expect(schemes[0].owning_organisation).not_to eq(different_organisation)
      end

      it "does not update the lettings log if scheme owning organisation didn't change" do
        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)

        lettings_log.reload
        expect(lettings_log.scheme).not_to be_nil
        expect(lettings_log.location).not_to be_nil
      end

      it "only re-exports the logs for the schemes that have been updated" do
        lettings_log_4.startdate = Time.zone.local(2022, 4, 1)
        lettings_log_4.save!(validate: false)
        lettings_log_5.startdate = Time.zone.local(2021, 4, 1)
        lettings_log_5.save!(validate: false)
        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)

        lettings_log.reload
        expect(lettings_log.values_updated_at).not_to eq(nil)

        lettings_log_2.reload
        expect(lettings_log_2.values_updated_at).to eq(nil)

        lettings_log_3.reload
        expect(lettings_log_3.values_updated_at).to eq(nil)

        lettings_log_4.reload
        expect(lettings_log_4.values_updated_at).not_to eq(nil)

        lettings_log_5.reload
        expect(lettings_log_5.values_updated_at).to eq(nil)
      end

      it "logs the progress of the update" do
        create(:organisation_relationship, parent_organisation: schemes[0].owning_organisation, child_organisation: different_organisation)

        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with service_name: Updated test name")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with sensitive: No")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with scheme_type: Direct Access Hostel")
        expect(Rails.logger).to receive(:info).with("Clearing location and scheme for logs with startdate and scheme S#{schemes[0].id}. Log IDs: ")
        expect(Rails.logger).to receive(:info).with(match(/^Clearing location and scheme for logs without startdate and scheme S#{schemes[0].id}\. Log IDs: (?=.*#{lettings_log.id})(?=.*#{lettings_log_4.id})(?=.*#{lettings_log_5.id}).*$/))
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with arrangement_type: Another registered stock owner")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with primary_client_group: People with drug problems")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with has_other_client_group: No")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with support_type: Low level")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with intended_stay: Permanent")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with registered_under_care_act: No")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with owning_organisation: Different organisation")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[0].id} with status as it it not a permitted field")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[0].id} with created_at as it it not a permitted field")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[0].id} with active_dates as it it not a permitted field")
        expect(Rails.logger).to receive(:info).with("Saved scheme S#{schemes[0].id}.")

        expect(Rails.logger).to receive(:info).with("No changes to scheme S#{schemes[1].id}.")

        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with sensitive: Yse. 'Yse' is not a valid sensitive")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with scheme_type: Direct access Hostel. 'Direct access Hostel' is not a valid scheme_type")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with owning_organisation: non existing org. Organisation with name non existing org is not in the database or is not related to current organisation")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with arrangement_type: wrong answer. 'wrong answer' is not a valid arrangement_type")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with primary_client_group: FD. 'FD' is not a valid primary_client_group")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with has_other_client_group: no. 'no' is not a valid has_other_client_group")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with secondary_client_group: lder people with support needs. 'lder people with support needs' is not a valid secondary_client_group")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with support_type: high. 'high' is not a valid support_type")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with intended_stay: Permanent . 'Permanent ' is not a valid intended_stay")

        expect(Rails.logger).to receive(:info).with("No changes to scheme S#{schemes[2].id}.")

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

      it "logs an error if a validation fails and processes the rest of the rows" do
        create(:organisation_relationship, parent_organisation: schemes[0].owning_organisation, child_organisation: different_organisation)
        lettings_log_4.startdate = Time.zone.local(2022, 4, 1)
        lettings_log_4.save!(validate: false)
        lettings_log_5.startdate = Time.zone.local(2021, 4, 1)
        lettings_log_5.save!(validate: false)

        schemes[1].support_type = nil
        schemes[1].save!(validate: false)
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with service_name: Updated test name")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with sensitive: No")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with scheme_type: Direct Access Hostel")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with arrangement_type: Another registered stock owner")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with primary_client_group: People with drug problems")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with has_other_client_group: No")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with support_type: Low level")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with intended_stay: Permanent")
        expect(Rails.logger).to receive(:info).with("Updating scheme S#{schemes[0].id} with registered_under_care_act: No")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[0].id} with status as it it not a permitted field")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[0].id} with created_at as it it not a permitted field")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[0].id} with active_dates as it it not a permitted field")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[0].id} with owning_organisation: Different organisation. There are lettings logs from closed collection period using this scheme")
        expect(Rails.logger).to receive(:info).with("Saved scheme S#{schemes[0].id}.")
        expect(Rails.logger).to receive(:info).with("Will not export log #{lettings_log_5.id} as it is before the exportable date")

        expect(Rails.logger).to receive(:info).with("No changes to scheme S#{schemes[1].id}.")

        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with sensitive: Yse. 'Yse' is not a valid sensitive")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with scheme_type: Direct access Hostel. 'Direct access Hostel' is not a valid scheme_type")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with owning_organisation: non existing org. Organisation with name non existing org is not in the database or is not related to current organisation")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with arrangement_type: wrong answer. 'wrong answer' is not a valid arrangement_type")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with primary_client_group: FD. 'FD' is not a valid primary_client_group")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with has_other_client_group: no. 'no' is not a valid has_other_client_group")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with secondary_client_group: lder people with support needs. 'lder people with support needs' is not a valid secondary_client_group")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with support_type: high. 'high' is not a valid support_type")
        expect(Rails.logger).to receive(:info).with("Cannot update scheme S#{schemes[2].id} with intended_stay: Permanent . 'Permanent ' is not a valid intended_stay")
        expect(Rails.logger).to receive(:info).with("No changes to scheme S#{schemes[2].id}.")

        expect(Rails.logger).to receive(:info).with("Scheme with id Wrong_id is not in the original scheme csv")
        expect(Rails.logger).to receive(:info).with("Scheme with id SWrong_id is not in the database")

        task.invoke(original_schemes_csv_path, updated_schemes_csv_path)
      end
    end
  end

  describe ":update_locations_from_csv", type: :task do
    subject(:task) { Rake::Task["bulk_update:update_locations_from_csv"] }

    let(:instance_name) { "import_instance" }
    let(:storage_service) { instance_double(Storage::S3Service) }
    let(:env_config_service) { instance_double(Configuration::EnvConfigurationService) }

    before do
      Rake.application.rake_require("tasks/update_schemes_and_locations_from_csv")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:original_locations_csv_path) { "original_locations.csv" }
      let(:updated_locations_csv_path) { "updated_locations.csv" }
      let(:wrong_file_path) { "/test/no_csv_here.csv" }
      let!(:scheme) { FactoryBot.create(:scheme, service_name: "Scheme 1") }
      let!(:different_scheme) { FactoryBot.create(:scheme, service_name: "Different scheme", owning_organisation: scheme.owning_organisation) }

      let(:locations) do
        create_list(:location,
                    3,
                    postcode: "SW1A 2AA",
                    name: "Downing Street",
                    type_of_unit: "Self-contained house",
                    units: 20,
                    mobility_type: "Fitted with equipment and adaptations",
                    location_code: "E08000010",
                    location_admin_district: "Wigan",
                    startdate: Time.zone.local(2022, 4, 1),
                    confirmed: true,
                    updated_at: Time.zone.local(2022, 3, 1),
                    scheme:)
      end
      let!(:lettings_log) { FactoryBot.create(:lettings_log, :sh, owning_organisation: scheme.owning_organisation, location: locations[0], scheme:, values_updated_at: nil, startdate: Time.zone.local(2023, 4, 4)) }
      let!(:lettings_log_2) { FactoryBot.create(:lettings_log, :sh, owning_organisation: scheme.owning_organisation, location: locations[1], scheme:, values_updated_at: nil, startdate: Time.zone.local(2023, 4, 4)) }
      let!(:lettings_log_3) { FactoryBot.create(:lettings_log, :sh, owning_organisation: scheme.owning_organisation, location: locations[2], scheme:, values_updated_at: nil, startdate: Time.zone.local(2023, 4, 4)) }
      let!(:lettings_log_4) { FactoryBot.create(:lettings_log, :sh, owning_organisation: scheme.owning_organisation, location: locations[0], scheme:, values_updated_at: nil, startdate: Time.zone.local(2023, 4, 4)) }
      let!(:lettings_log_5) { FactoryBot.create(:lettings_log, :sh, owning_organisation: scheme.owning_organisation, location: locations[0], scheme:, values_updated_at: nil, startdate: Time.zone.local(2023, 4, 4)) }

      before do
        allow(storage_service).to receive(:get_file_io)
        .with("original_locations.csv")
        .and_return(StringIO.new(replace_entity_ids_for_locations(locations[0], locations[1], locations[2], scheme, scheme, scheme, File.open("./spec/fixtures/files/original_locations.csv").read)))

        allow(storage_service).to receive(:get_file_io)
        .with("updated_locations.csv")
        .and_return(StringIO.new(replace_entity_ids_for_locations(locations[0], locations[1], locations[2], different_scheme, scheme, { id: "non existent scheme id" }, File.open("./spec/fixtures/files/updated_locations.csv").read)))
      end

      it "updates the allowed location fields if they have changed and doesn't update other fields" do
        task.invoke(original_locations_csv_path, updated_locations_csv_path)
        locations[0].reload
        expect(locations[0].postcode).to eq("B1 1BB")
        expect(locations[0].name).to eq("Updated name")
        expect(locations[0].type_of_unit).to eq("Bungalow")
        expect(locations[0].units).to eq(10)
        expect(locations[0].mobility_type).to eq("Wheelchair-user standard")
        expect(locations[0].location_code).to eq("E09000033")
        expect(locations[0].location_admin_district).to eq("Westminster")
        expect(locations[0].scheme).to eq(different_scheme)
      end

      it "does not update the location if it hasn't changed" do
        task.invoke(original_locations_csv_path, updated_locations_csv_path)
        locations[1].reload
        expect(locations[1].postcode).to eq("SW1A 2AA")
        expect(locations[1].name).to eq("Downing Street")
        expect(locations[1].type_of_unit).to eq("Self-contained house")
        expect(locations[1].units).to eq(20)
        expect(locations[1].mobility_type).to eq("Fitted with equipment and adaptations")
        expect(locations[1].location_code).to eq("E08000010")
        expect(locations[1].location_admin_district).to eq("Wigan")
        expect(locations[1].scheme).to eq(scheme)
      end

      it "does not update the location with invalid values" do
        task.invoke(original_locations_csv_path, updated_locations_csv_path)
        locations[2].reload
        expect(locations[2].postcode).to eq("SW1A 2AA")
        expect(locations[2].name).to eq("Downing Street")
        expect(locations[2].type_of_unit).to eq("Self-contained house")
        expect(locations[2].units).to eq(20)
        expect(locations[2].mobility_type).to eq("Fitted with equipment and adaptations")
        expect(locations[2].location_code).to eq("E08000010")
        expect(locations[2].location_admin_district).to eq("Wigan")
        expect(locations[2].scheme).to eq(scheme)
      end

      it "does not update the scheme id if the new scheme is not in the same or related organisation as the old scheme" do
        different_scheme.update!(owning_organisation: FactoryBot.create(:organisation))
        task.invoke(original_locations_csv_path, updated_locations_csv_path)
        locations[0].reload
        expect(locations[0].scheme).not_to eq(different_scheme)
      end

      it "only re-exports the logs for the locations that have been updated" do
        lettings_log_4.startdate = Time.zone.local(2022, 4, 1)
        lettings_log_4.save!(validate: false)
        lettings_log_5.startdate = Time.zone.local(2021, 4, 1)
        lettings_log_5.save!(validate: false)

        task.invoke(original_locations_csv_path, updated_locations_csv_path)

        lettings_log.reload
        expect(lettings_log.values_updated_at).not_to eq(nil)

        lettings_log_2.reload
        expect(lettings_log_2.values_updated_at).to eq(nil)

        lettings_log_3.reload
        expect(lettings_log_3.values_updated_at).to eq(nil)

        lettings_log_4.reload
        expect(lettings_log_4.values_updated_at).not_to eq(nil)

        lettings_log_5.reload
        expect(lettings_log_5.values_updated_at).to eq(nil)
      end

      it "logs the progress of the update" do
        lettings_log_4.startdate = Time.zone.local(2022, 4, 1)
        lettings_log_4.save!(validate: false)
        lettings_log_5.startdate = Time.zone.local(2021, 4, 1)
        lettings_log_5.save!(validate: false)

        expect(Rails.logger).to receive(:info).with("Updating location #{locations[0].id} with scheme: S#{different_scheme.id}")
        expect(Rails.logger).to receive(:info).with("Clearing location and scheme for logs with startdate and location #{locations[0].id}. Log IDs: #{lettings_log.id}")
        expect(Rails.logger).to receive(:info).with("Clearing location and scheme for logs without startdate and location #{locations[0].id}. Log IDs: ")
        expect(Rails.logger).to receive(:info).with("Clearing location and scheme for non editable logs with location #{locations[0].id}. Log IDs: #{lettings_log_4.id}")
        expect(Rails.logger).to receive(:info).with("Updating location #{locations[0].id} with postcode: B11BB")
        expect(Rails.logger).to receive(:info).with("Updating location #{locations[0].id} with name: Updated name")
        expect(Rails.logger).to receive(:info).with("Updating location #{locations[0].id} with location_code: E09000033")
        expect(Rails.logger).to receive(:info).with("Updating location #{locations[0].id} with type_of_unit: Bungalow")
        expect(Rails.logger).to receive(:info).with("Updating location #{locations[0].id} with units: 10")
        expect(Rails.logger).to receive(:info).with("Updating location #{locations[0].id} with mobility_type: Wheelchair-user standard")
        expect(Rails.logger).to receive(:info).with("Cannot update location #{locations[0].id} with status as it it not a permitted field")
        expect(Rails.logger).to receive(:info).with("Cannot update location #{locations[0].id} with active_dates as it it not a permitted field")
        expect(Rails.logger).to receive(:info).with("Saved location #{locations[0].id}.")

        expect(Rails.logger).to receive(:info).with("Will not export log #{lettings_log_5.id} as it is before the exportable date")
        expect(Rails.logger).to receive(:info).with("No changes to location #{locations[1].id}.")

        expect(Rails.logger).to receive(:info).with("Cannot update location #{locations[2].id} with postcode: SWAAA. Enter a postcode in the correct format, for example AA1 1AA.")
        expect(Rails.logger).to receive(:info).with("Cannot update location #{locations[2].id} with scheme_code: S. Scheme with id S is not in the database")
        expect(Rails.logger).to receive(:info).with("Cannot update location #{locations[2].id} with location_admin_district: Westminst. Location admin distrint Westminst is not a valid option")
        expect(Rails.logger).to receive(:info).with("Cannot update location #{locations[2].id} with type_of_unit: elf-contained house. 'elf-contained house' is not a valid type_of_unit")
        expect(Rails.logger).to receive(:info).with("Cannot update location #{locations[2].id} with mobility_type: 55. '55' is not a valid mobility_type")
        expect(Rails.logger).to receive(:info).with("Cannot update location #{locations[2].id} with status as it it not a permitted field")

        expect(Rails.logger).to receive(:info).with("No changes to location #{locations[2].id}.")

        expect(Rails.logger).to receive(:info).with("Location with id Wrong_id is not in the original location csv")
        expect(Rails.logger).to receive(:info).with("Location with id SWrong_id is not in the database")

        task.invoke(original_locations_csv_path, updated_locations_csv_path)
      end

      it "raises an error when no paths are given" do
        expect { task.invoke(nil) }.to raise_error(RuntimeError, "Usage: rake bulk_update:update_locations_from_csv['original_file_name','updated_file_name']")
      end

      it "raises an error when no original path is given" do
        expect { task.invoke(nil, updated_locations_csv_path) }.to raise_error(RuntimeError, "Usage: rake bulk_update:update_locations_from_csv['original_file_name','updated_file_name']")
      end

      it "raises an error when no updated path is given" do
        expect { task.invoke(original_locations_csv_path, nil) }.to raise_error(RuntimeError, "Usage: rake bulk_update:update_locations_from_csv['original_file_name','updated_file_name']")
      end

      context "when updating LA" do
        before do
          LaRentRange.create!(
            ranges_rent_id: "1",
            la: "E09000033",
            beds: 0,
            lettype: 8,
            soft_min: 12.41,
            soft_max: 89.54,
            hard_min: 9.87,
            hard_max: 100.99,
            start_year: 2023,
          )
        end

        context "when new LA does not trigger hard rent ranges validations" do
          let!(:lettings_log) do
            FactoryBot.create(:lettings_log,
                              :completed,
                              :sh,
                              location: locations[0],
                              scheme:,
                              values_updated_at: nil,
                              owning_organisation: scheme.owning_organisation,
                              brent: 80,
                              scharge: 50,
                              pscharge: 50,
                              supcharg: 50,
                              beds: 4,
                              lettype: 1,
                              period: 1)
          end

          before do
            allow(storage_service).to receive(:get_file_io)
            .with("updated_locations.csv")
            .and_return(StringIO.new(replace_entity_ids_for_locations(locations[0], locations[1], locations[2], scheme, scheme, { id: "non existent scheme id" }, File.open("./spec/fixtures/files/updated_locations.csv").read)))
          end

          it "does not clear the charges values" do
            expect(lettings_log.status).to eq("completed")
            task.invoke(original_locations_csv_path, updated_locations_csv_path)
            lettings_log.reload
            expect(lettings_log.status).to eq("completed")
            expect(lettings_log.brent).to eq(80)
            expect(lettings_log.scharge).to eq(50)
            expect(lettings_log.pscharge).to eq(50)
            expect(lettings_log.supcharg).to eq(50)
          end
        end

        context "when new LA triggers hard rent ranges validation" do
          let!(:lettings_log) do
            FactoryBot.create(:lettings_log,
                              :completed,
                              :sh,
                              location: locations[0],
                              scheme:,
                              values_updated_at: nil,
                              owning_organisation: scheme.owning_organisation,
                              brent: 200,
                              scharge: 50,
                              pscharge: 50,
                              supcharg: 50,
                              beds: 4,
                              lettype: 1,
                              period: 1)
          end

          before do
            allow(storage_service).to receive(:get_file_io)
            .with("updated_locations.csv")
            .and_return(StringIO.new(replace_entity_ids_for_locations(locations[0], locations[1], locations[2], scheme, scheme, { id: "non existent scheme id" }, File.open("./spec/fixtures/files/updated_locations.csv").read)))
          end

          it "clears the charges values" do
            expect(lettings_log.status).to eq("completed")
            task.invoke(original_locations_csv_path, updated_locations_csv_path)
            lettings_log.reload
            expect(lettings_log.status).to eq("in_progress")
            expect(lettings_log.brent).to be_nil
            expect(lettings_log.scharge).to be_nil
            expect(lettings_log.pscharge).to be_nil
            expect(lettings_log.supcharg).to be_nil
          end
        end

        context "when new LA triggers soft rent ranges validations" do
          let!(:lettings_log) do
            FactoryBot.create(:lettings_log,
                              :completed,
                              :sh,
                              location: locations[0],
                              scheme:,
                              values_updated_at: nil,
                              owning_organisation: scheme.owning_organisation,
                              brent: 100,
                              scharge: 50,
                              pscharge: 50,
                              supcharg: 50,
                              beds: 4,
                              lettype: 1,
                              period: 1)
          end

          before do
            allow(storage_service).to receive(:get_file_io)
            .with("updated_locations.csv")
            .and_return(StringIO.new(replace_entity_ids_for_locations(locations[0], locations[1], locations[2], scheme, scheme, { id: "non existent scheme id" }, File.open("./spec/fixtures/files/updated_locations.csv").read)))
          end

          it "does not clear the charges values and marks the log in progress" do
            expect(lettings_log.status).to eq("completed")
            task.invoke(original_locations_csv_path, updated_locations_csv_path)
            lettings_log.reload
            expect(lettings_log.status).to eq("in_progress")
            expect(lettings_log.rent_value_check).to eq(nil)
            expect(lettings_log.brent).to eq(100)
            expect(lettings_log.scharge).to eq(50)
            expect(lettings_log.pscharge).to eq(50)
            expect(lettings_log.supcharg).to eq(50)
          end
        end

        context "when new LA triggers soft rent ranges validations for closed collection period" do
          let!(:lettings_log) do
            FactoryBot.create(:lettings_log,
                              :completed,
                              :sh,
                              location: locations[0],
                              scheme:,
                              values_updated_at: nil,
                              owning_organisation: scheme.owning_organisation,
                              brent: 100,
                              scharge: 50,
                              pscharge: 50,
                              supcharg: 50,
                              beds: 4,
                              lettype: 1,
                              voiddate: Time.zone.local(2020, 4, 1),
                              mrcdate: Time.zone.local(2020, 4, 1),
                              period: 1)
          end

          before do
            LaRentRange.create!(
              ranges_rent_id: "1",
              la: "E09000033",
              beds: 0,
              lettype: 8,
              soft_min: 12.41,
              soft_max: 89.54,
              hard_min: 9.87,
              hard_max: 100.99,
              start_year: 2022,
            )

            allow(storage_service).to receive(:get_file_io)
            .with("updated_locations.csv")
            .and_return(StringIO.new(replace_entity_ids_for_locations(locations[0], locations[1], locations[2], scheme, scheme, { id: "non existent scheme id" }, File.open("./spec/fixtures/files/updated_locations.csv").read)))

            lettings_log.startdate = Time.zone.local(2022, 4, 1)
            lettings_log.owning_organisation = scheme.owning_organisation
            lettings_log.save!(validate: false)
          end

          it "does not clear the charges values and confirms the rent value check" do
            expect(lettings_log.status).to eq("completed")
            task.invoke(original_locations_csv_path, updated_locations_csv_path)
            lettings_log.reload
            expect(lettings_log.status).to eq("completed")
            expect(lettings_log.rent_value_check).to eq(0)
            expect(lettings_log.brent).to eq(100)
            expect(lettings_log.scharge).to eq(50)
            expect(lettings_log.pscharge).to eq(50)
            expect(lettings_log.supcharg).to eq(50)
          end
        end
      end
    end
  end
end
