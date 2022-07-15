require "rails_helper"

RSpec.describe Imports::SchemeImportService do
  subject(:scheme_service) { described_class.new(storage_service, logger) }

  let(:storage_service) { instance_double(StorageService) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:fixture_directory) { "spec/fixtures/imports/schemes" }
  let(:scheme_id) { "6d6d7618b58affe2a150a5ef2e9f4765fa6cd05d" }

  let!(:owning_org) { FactoryBot.create(:organisation, old_org_id: "7c5bd5fb549c09z2c55d9cb90d7ba84927e64618") }
  let!(:managing_org) { FactoryBot.create(:organisation, old_visible_id: 456) }

  def open_file(directory, filename)
    File.open("#{directory}/#{filename}.xml")
  end

  context "when importing schemes" do
    let(:remote_folder) { "mgmtgroups" }

    before do
      # Stub the S3 file listing and download
      allow(storage_service).to receive(:list_files)
                                  .and_return(%W[#{remote_folder}/#{scheme_id}.xml])
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{scheme_id}.xml")
                                  .and_return(open_file(fixture_directory, scheme_id))
    end

    it "successfully create all schemes" do
      expect(logger).not_to receive(:error)
      expect(logger).not_to receive(:warn)
      expect(logger).not_to receive(:info)
      expect { scheme_service.create_schemes(remote_folder) }
        .to change(Scheme, :count).by(1)
    end
  end

  context "when importing a specific scheme" do
    let(:scheme_file) { open_file(fixture_directory, scheme_id) }
    let(:scheme_xml) { Nokogiri::XML(scheme_file) }

    it "matches expected values" do
      scheme = scheme_service.create_scheme(scheme_xml)
      expect(scheme.owning_organisation).to eq(owning_org)
      expect(scheme.managing_organisation).to eq(managing_org)
      expect(scheme.old_id).to eq("6d6d7618b58affe2a150a5ef2e9f4765fa6cd05d")
      expect(scheme.old_visible_id).to eq(123)
      expect(scheme.service_name).to eq("Management Group")
      expect(scheme.arrangement_type).to eq("O")
    end

    context "and the scheme status is not approved" do
      before { scheme_xml.at_xpath("//mgmtgroup:status").content = "Temporary" }

      it "does not create the scheme" do
        expect(logger).to receive(:warn).with("Scheme with legacy ID 6d6d7618b58affe2a150a5ef2e9f4765fa6cd05d is not approved (Temporary), skipping")
        expect { scheme_service.create_scheme(scheme_xml) }
          .not_to change(Scheme, :count)
      end
    end

    context "and the scheme arrange type is direct" do
      before do
        scheme_xml.at_xpath("//mgmtgroup:arrangement_type").content = "D"
        scheme_xml.at_xpath("//mgmtgroup:agent").content = ""
      end

      it "assigns both owning and managing organisation to the same one" do
        scheme = scheme_service.create_scheme(scheme_xml)
        expect(scheme.owning_organisation).to eq(owning_org)
        expect(scheme.managing_organisation).to eq(owning_org)
      end
    end
  end
end
