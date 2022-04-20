require "rails_helper"

RSpec.describe Imports::OrganisationLaImportService do
  let(:fixture_directory) { "spec/fixtures/softwire_imports/organisation_las" }
  let(:old_org_id) { "44026acc7ed5c29516b26f2a5deb639e5e37966d" }
  let(:old_id) { "00013f30e159d7f72a3abe9ea93fb5b685d311e4" }
  let(:import_file) { File.open("#{fixture_directory}/#{old_id}.xml") }
  let(:storage_service) { instance_double(StorageService) }

  context "when importing data protection confirmations" do
    subject(:import_service) { described_class.new(storage_service) }

    before do
      allow(storage_service)
        .to receive(:list_files)
        .and_return(["organisation_la_directory/#{old_id}.xml"])
      allow(storage_service)
        .to receive(:get_file_io)
        .with("organisation_la_directory/#{old_id}.xml")
        .and_return(import_file)
    end

    context "when the organisation in the import file doesn't exist in the system" do
      it "does not create an organisation la record" do
        expect { import_service.create_organisation_las("organisation_la_directory") }
          .to raise_error(ActiveRecord::RecordInvalid, /Organisation must exist/)
      end
    end

    context "when the organisation does exist" do
      let!(:organisation) { FactoryBot.create(:organisation, old_org_id:) }

      it "successfully create an organisation la record with the expected data" do
        import_service.create_organisation_las("organisation_la_directory")
        expect(Organisation.find_by(old_org_id:).organisation_las.pluck("ons_code")).to eq(["E07000041"])
      end
    end
  end
end
