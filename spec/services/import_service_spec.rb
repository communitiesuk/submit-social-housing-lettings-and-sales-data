require "rails_helper"

RSpec.describe ImportService do
  let(:storage_service) { instance_double(StorageService) }
  let(:folder_name) { "organisations" }
  let(:filenames) { %w[my_folder/my_file1.xml my_folder/my_file2.xml] }
  let(:fixture_directory) { "spec/fixtures/softwire_imports/organisations" }

  def create_organisation_file(fixture_directory, visible_id, name = "my_organisation")
    file = File.open("#{fixture_directory}/7c5bd5fb549c09a2c55d7cb90d7ba84927e64618.xml")
    doc =  Nokogiri::XML(file)
    doc.at_xpath("//institution:visible-id").content = visible_id
    doc.at_xpath("//institution:name").content = name
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

    it "successfully create a new organisation if it does not exist" do
      expect(storage_service).to receive(:list_files).with(folder_name)
      expect(storage_service).to receive(:get_file_io).with(filenames[0]).ordered
      expect(storage_service).to receive(:get_file_io).with(filenames[1]).ordered

      expect { import_service.update_organisations(folder_name) }.to change(Organisation, :count).by(2)
      expect(Organisation).to exist(old_visible_id: 1)
      expect(Organisation).to exist(old_visible_id: 2)
    end
  end

  context "when importing organisations with duplicate old visible ID" do
    subject(:import_service) { described_class.new(storage_service) }

    before do
      allow(storage_service).to receive(:list_files).and_return([filenames[0]])
      allow(storage_service).to receive(:get_file_io).and_return(
        create_organisation_file(fixture_directory, 1),
        create_organisation_file(fixture_directory, 1, "my_new_organisation"),
      )
    end

    it "successfully create and update an organisation" do
      expect(storage_service).to receive(:list_files).with(folder_name).twice
      expect(storage_service).to receive(:get_file_io).with(filenames[0]).twice

      expect { import_service.update_organisations(folder_name) }.to change(Organisation, :count).by(1)
      expect { import_service.update_organisations(folder_name) }.to change(Organisation, :count).by(0)

      organisation = Organisation.find_by(old_visible_id: 1)
      expect(organisation).to_not be_nil
      expect(organisation.name).to eq("my_new_organisation")
    end
  end
end
