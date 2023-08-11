require "rails_helper"

RSpec.describe Imports::OrganisationRelationshipImportService do
  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:logger) { instance_double(Rails::Rack::Logger) }
  let(:folder_name) { "organisation_relationships" }
  let(:filenames) { %w[my_folder/my_file1.xml my_folder/my_file2.xml] }
  let(:fixture_directory) { "spec/fixtures/imports/institution-link" }
  let!(:child_organisation) { create(:organisation, old_visible_id: 1) }
  let!(:parent_organisation) { create(:organisation, old_visible_id: 2) }
  let!(:grandparent_organisation) { create(:organisation, old_visible_id: 3) }

  def create_organisation_relationship_file(fixture_directory, child_organisation_id, parent_organisation_id)
    file = File.open("#{fixture_directory}/test_institution_link.xml")
    doc =  Nokogiri::XML(file)
    doc.at_xpath("//institution-link:parent-institution").content = parent_organisation_id if parent_organisation_id
    doc.at_xpath("//institution-link:child-institution").content = child_organisation_id if child_organisation_id
    StringIO.new(doc.to_xml)
  end

  context "when importing organisation relationships" do
    subject(:import_service) { described_class.new(storage_service) }

    before do
      allow(storage_service).to receive(:list_files)
                                   .and_return(filenames)
      allow(storage_service).to receive(:get_file_io)
                                   .with(filenames[0])
                                   .and_return(create_organisation_relationship_file(fixture_directory, 1, 2))
      allow(storage_service).to receive(:get_file_io)
                                   .with(filenames[1])
                                   .and_return(create_organisation_relationship_file(fixture_directory, 2, 3))
    end

    it "successfully create an organisation relationship with the expected data" do
      import_service.create_organisation_relationships(folder_name)

      organisation_relationship = OrganisationRelationship.find { |r| r.child_organisation == child_organisation }
      expect(organisation_relationship.child_organisation).to eq(child_organisation)
      expect(organisation_relationship.parent_organisation).to eq(parent_organisation)
    end

    it "doesn't re-import duplicates" do
      import_service.create_organisation_relationships(folder_name)
      import_service.create_organisation_relationships(folder_name)

      expect(OrganisationRelationship.count).to eq(2)
    end

    it "successfully creates multiple organisation relationships" do
      expect(storage_service).to receive(:list_files).with(folder_name)
      expect(storage_service).to receive(:get_file_io).with(filenames[0]).ordered
      expect(storage_service).to receive(:get_file_io).with(filenames[1]).ordered

      expect { import_service.create_organisation_relationships(folder_name) }.to change(OrganisationRelationship, :count).by(2)
      expect(OrganisationRelationship).to exist(child_organisation:, parent_organisation:)
      expect(OrganisationRelationship).to exist(child_organisation: parent_organisation, parent_organisation: grandparent_organisation)
    end
  end
end
