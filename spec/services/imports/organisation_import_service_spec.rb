require "rails_helper"

RSpec.describe Imports::OrganisationImportService do
  let(:storage_service) { instance_double(StorageService) }
  let(:logger) { instance_double(Rails::Rack::Logger) }
  let(:folder_name) { "organisations" }
  let(:filenames) { %w[my_folder/my_file1.xml my_folder/my_file2.xml] }
  let(:fixture_directory) { "spec/fixtures/imports/organisations" }

  def create_organisation_file(fixture_directory, visible_id, name = nil)
    file = File.open("#{fixture_directory}/7c5bd5fb549c09a2c55d7cb90d7ba84927e64618.xml")
    doc =  Nokogiri::XML(file)
    doc.at_xpath("//institution:visible-id").content = visible_id if visible_id
    doc.at_xpath("//institution:name").content = name if name
    StringIO.new(doc.to_xml)
  end

  context "when importing organisations" do
    subject(:import_service) { described_class.new(storage_service) }

    before do
      allow(storage_service).to receive(:list_files)
                                   .and_return(filenames)
      allow(storage_service).to receive(:get_file_io)
                                   .with(filenames[0])
                                   .and_return(create_organisation_file(fixture_directory, 1))
      allow(storage_service).to receive(:get_file_io)
                                   .with(filenames[1])
                                   .and_return(create_organisation_file(fixture_directory, 2))
    end

    it "successfully create an organisation with the expected data" do
      import_service.create_organisations(folder_name)

      organisation = Organisation.find_by(old_visible_id: 1)
      expect(organisation.name).to eq("HA Ltd")
      expect(organisation.provider_type).to eq("PRP")
      expect(organisation.phone).to eq("xxxxxxxx")
      expect(organisation.holds_own_stock).to be_truthy
      expect(organisation.active).to be_truthy
      # expect(organisation.old_association_type).to eq() string VS integer
      # expect(organisation.software_supplier_id).to eq() boolean VS string
      expect(organisation.housing_management_system).to eq("") # Need examples
      expect(organisation.choice_based_lettings).to be_falsey
      expect(organisation.common_housing_register).to be_falsey
      expect(organisation.choice_allocation_policy).to be_falsey
      expect(organisation.cbl_proportion_percentage).to be_nil # Need example
      expect(organisation.enter_affordable_logs).to be_truthy
      expect(organisation.owns_affordable_logs).to be_truthy # owns_affordable_rent
      expect(organisation.housing_registration_no).to eq("LH9999")
      expect(organisation.general_needs_units).to eq(1104)
      expect(organisation.supported_housing_units).to eq(217)
      expect(organisation.unspecified_units).to eq(0)
      expect(organisation.unspecified_units).to eq(0)
      expect(organisation.old_org_id).to eq("7c5bd5fb549c09z2c55d9cb90d7ba84927e64618")
      expect(organisation.old_visible_id).to eq(1)
    end

    it "successfully create multiple organisations" do
      expect(storage_service).to receive(:list_files).with(folder_name)
      expect(storage_service).to receive(:get_file_io).with(filenames[0]).ordered
      expect(storage_service).to receive(:get_file_io).with(filenames[1]).ordered

      expect { import_service.create_organisations(folder_name) }.to change(Organisation, :count).by(2)
      expect(Organisation).to exist(old_visible_id: 1)
      expect(Organisation).to exist(old_visible_id: 2)
    end
  end

  context "when importing organisations twice" do
    subject(:import_service) { described_class.new(storage_service, logger) }

    before do
      allow(storage_service).to receive(:list_files).and_return([filenames[0]])
      allow(storage_service).to receive(:get_file_io).and_return(
        create_organisation_file(fixture_directory, 1),
        create_organisation_file(fixture_directory, 1, "my_new_organisation"),
      )
    end

    it "successfully create an organisation the first time, and does not update it" do
      expect(storage_service).to receive(:list_files).with(folder_name).twice
      expect(storage_service).to receive(:get_file_io).with(filenames[0]).twice
      expect(logger).to receive(:warn).once

      expect { import_service.create_organisations(folder_name) }.to change(Organisation, :count).by(1)
      expect { import_service.create_organisations(folder_name) }.to change(Organisation, :count).by(0)

      expect(Organisation).to exist(old_visible_id: 1, name: "HA Ltd")
    end
  end
end
