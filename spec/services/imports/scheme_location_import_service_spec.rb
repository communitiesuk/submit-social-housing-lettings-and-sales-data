require "rails_helper"

RSpec.describe Imports::SchemeLocationImportService do
  subject(:location_service) { described_class.new(storage_service, logger) }

  let(:storage_service) { instance_double(StorageService) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:fixture_directory) { "spec/fixtures/imports/scheme_locations" }
  let(:first_location_id) { "0ae7ad6dc0f1cf7ef33c18cc8c108bebc1b4923e" }
  let(:second_location_id) { "0bb3836b70b4dd9903263d5a764a5c45b964a89d" }

  let!(:scheme) { FactoryBot.create(:scheme, service_name: "Management Group", old_id: "6d6d7618b58affe2a150a5ef2e9f4765fa6cd05d") }

  def open_file(directory, filename)
    File.open("#{directory}/#{filename}.xml")
  end

  context "when importing scheme locations" do
    let(:remote_folder) { "schemes" }

    before do
      # Stub the S3 file listing and download
      allow(storage_service).to receive(:list_files)
                                  .and_return(%W[#{remote_folder}/#{first_location_id}.xml #{remote_folder}/#{second_location_id}.xml])
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{first_location_id}.xml")
                                  .and_return(open_file(fixture_directory, first_location_id))
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{second_location_id}.xml")
                                  .and_return(open_file(fixture_directory, second_location_id))
    end

    it "successfully create all scheme locations" do
      expect(logger).not_to receive(:error)
      expect(logger).not_to receive(:warn)
      expect(logger).not_to receive(:info)
      expect { location_service.create_scheme_locations(remote_folder) }
        .to change(Location, :count).by(2)
        .and(change(Scheme, :count).by(0))
    end
  end

  context "when importing different scheme locations" do
    let(:location_xml_1) { Nokogiri::XML(open_file(fixture_directory, first_location_id)) }
    let(:location_xml_2) { Nokogiri::XML(open_file(fixture_directory, second_location_id)) }

    before { location_service.create_scheme_location(location_xml_1) }

    context "and the scheme type is different" do
      before { location_xml_2.at_xpath("//scheme:scheme-type").content = "5" }

      it "renames the location scheme name" do
        location = location_service.create_scheme_location(location_xml_2)
        old_scheme = Scheme.find(scheme.id)
        new_scheme = location.scheme

        expect(old_scheme.service_name).to eq("Management Group - Housing for older people")
        expect(new_scheme.service_name).to eq("Management Group - Direct Access Hostel")
      end
    end

    context "and the registered under care act is different" do
      before { location_xml_2.at_xpath("//scheme:reg-home-type").content = "2" }

      it "renames both scheme names" do
        location = location_service.create_scheme_location(location_xml_2)
        old_scheme = Scheme.find(scheme.id)
        new_scheme = location.scheme

        expect(old_scheme.service_name).to eq("Management Group")
        expect(new_scheme.service_name).to eq("Management Group - (Part-registered care home)")
      end
    end

    context "and the support type is different" do
      before { location_xml_2.at_xpath("//scheme:support-type").content = "3" }

      it "renames both scheme names" do
        location = location_service.create_scheme_location(location_xml_2)
        old_scheme = Scheme.find(scheme.id)
        new_scheme = location.scheme

        expect(old_scheme.service_name).to eq("Management Group - Low level")
        expect(new_scheme.service_name).to eq("Management Group - Medium level")
      end
    end

    context "and the intended stay is different" do
      before { location_xml_2.at_xpath("//scheme:intended-stay").content = "S" }

      it "renames both scheme names" do
        location = location_service.create_scheme_location(location_xml_2)
        old_scheme = Scheme.find(scheme.id)
        new_scheme = location.scheme

        expect(old_scheme.service_name).to eq("Management Group - Permanent")
        expect(new_scheme.service_name).to eq("Management Group - Short stay")
      end
    end

    context "and the primary client group is different" do
      before { location_xml_2.at_xpath("//scheme:client-group-1").content = "F" }

      it "renames both scheme names" do
        location = location_service.create_scheme_location(location_xml_2)
        old_scheme = Scheme.find(scheme.id)
        new_scheme = location.scheme

        expect(old_scheme.service_name).to eq("Management Group - Older people with support needs")
        expect(new_scheme.service_name).to eq("Management Group - People with drug problems")
      end
    end

    context "and the secondary client group is different" do
      before { location_xml_2.at_xpath("//scheme:client-group-2").content = "S" }

      it "renames both scheme names" do
        location = location_service.create_scheme_location(location_xml_2)
        old_scheme = Scheme.find(scheme.id)
        new_scheme = location.scheme

        expect(old_scheme.service_name).to eq("Management Group")
        expect(new_scheme.service_name).to eq("Management Group - Rough sleepers")
      end
    end
  end

  context "when importing a specific scheme location" do
    let(:location_xml) { Nokogiri::XML(open_file(fixture_directory, first_location_id)) }

    it "matches expected location values" do
      location = location_service.create_scheme_location(location_xml)
      expect(location.name).to eq("Location 1")
      expect(location.postcode).to eq("S44 6EJ")
      expect(location.units).to eq(5)
      expect(location.mobility_type).to eq("Fitted with equipment and adaptations")
      expect(location.type_of_unit).to eq("Bungalow")
      expect(location.old_id).to eq(first_location_id)
      expect(location.old_visible_id).to eq(10)
      expect(location.startdate).to eq("1900-01-01")
      expect(location.scheme).to eq(scheme)
    end

    it "matches expected schemes values" do
      location = location_service.create_scheme_location(location_xml)
      expect(location.scheme.scheme_type).to eq("Housing for older people")
      expect(location.scheme.registered_under_care_act).to eq("No")
      expect(location.scheme.support_type).to eq("Low level")
      expect(location.scheme.intended_stay).to eq("Permanent")
      expect(location.scheme.primary_client_group).to eq("Older people with support needs")
      expect(location.scheme.secondary_client_group).to be_nil
      expect(location.scheme.sensitive).to eq("No")
      expect(location.scheme.end_date).to eq("2050-12-31")
    end

    context "and the end date is before the current date" do
      before do
        Timecop.freeze(2022, 6, 1)
        location_xml.at_xpath("//scheme:end-date").content = "2022-05-01"
      end

      after { Timecop.unfreeze }

      it "does not create the location" do
        expect(logger).to receive(:warn).with("Location with legacy ID 0ae7ad6dc0f1cf7ef33c18cc8c108bebc1b4923e is expired (2022-05-01 00:00:00 +0100), skipping")
        expect { location_service.create_scheme_location(location_xml) }
          .not_to change(Location, :count)
      end
    end

    context "and we import the same location twice" do
      before { location_service.create_scheme_location(location_xml) }

      it "does not create the location" do
        expect(logger).to receive(:warn).with("Location is already present with legacy ID 0ae7ad6dc0f1cf7ef33c18cc8c108bebc1b4923e, skipping")
        expect { location_service.create_scheme_location(location_xml) }
          .not_to change(Location, :count)
      end
    end
  end
end
