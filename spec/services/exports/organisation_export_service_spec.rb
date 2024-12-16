require "rails_helper"

RSpec.describe Exports::OrganisationExportService do
  subject(:export_service) { described_class.new(storage_service, start_time) }

  let(:storage_service) { instance_double(Storage::S3Service) }

  let(:xml_export_file) { File.open("spec/fixtures/exports/organisation.xml", "r:UTF-8") }
  let(:local_manifest_file) { File.open("spec/fixtures/exports/manifest.xml", "r:UTF-8") }

  let(:expected_zip_filename) { "organisations_2024_2025_apr_mar_f0001_inc0001.zip" }
  let(:expected_data_filename) { "organisations_2024_2025_apr_mar_f0001_inc0001_pt001.xml" }
  let(:expected_manifest_filename) { "manifest.xml" }
  let(:start_time) { Time.zone.local(2022, 5, 1) }
  let(:organisation) { create(:organisation, with_dsa: false) }

  def replace_entity_ids(organisation, export_template)
    export_template.sub!(/\{id\}/, organisation["id"].to_s)
    export_template.sub!(/\{name\}/, organisation["name"])
    export_template.sub!(/\{dsa_signed_at\}/, organisation.data_protection_confirmation&.signed_at.to_s)
    export_template.sub!(/\{dpo_email\}/, organisation.data_protection_confirmation&.data_protection_officer_email)
  end

  def replace_record_number(export_template, record_number)
    export_template.sub!(/\{recno\}/, record_number.to_s)
  end

  before do
    Timecop.freeze(start_time)
    Singleton.__init__(FormHandler)
    allow(storage_service).to receive(:write_file)
  end

  after do
    Timecop.return
  end

  context "when exporting daily organisations in XML" do
    context "and no organisations are available for export" do
      it "returns an empty archives list" do
        expect(export_service.export_xml_organisations).to eq({})
      end
    end

    context "and one organisation is available for export" do
      let!(:organisation) { create(:organisation, name: "MHCLG", address_line1: "2 Marsham Street", address_line2: "London", postcode: "SW1P 4DF", housing_registration_no: "1234") }

      it "generates a ZIP export file with the expected filename" do
        expect(storage_service).to receive(:write_file).with(expected_zip_filename, any_args)
        export_service.export_xml_organisations
      end

      it "generates an XML export file with the expected filename within the ZIP file" do
        expect(storage_service).to receive(:write_file).with(expected_zip_filename, any_args) do |_, content|
          entry = Zip::File.open_buffer(content).find_entry(expected_data_filename)
          expect(entry).not_to be_nil
          expect(entry.name).to eq(expected_data_filename)
        end
        export_service.export_xml_organisations
      end

      it "generates an XML manifest file with the expected content within the ZIP file" do
        expected_content = replace_record_number(local_manifest_file.read, 1)
        expect(storage_service).to receive(:write_file).with(expected_zip_filename, any_args) do |_, content|
          entry = Zip::File.open_buffer(content).find_entry(expected_manifest_filename)
          expect(entry).not_to be_nil
          expect(entry.get_input_stream.read).to eq(expected_content)
        end

        export_service.export_xml_organisations
      end

      it "generates an XML export file with the expected content within the ZIP file" do
        expected_content = replace_entity_ids(organisation, xml_export_file.read)
        expect(storage_service).to receive(:write_file).with(expected_zip_filename, any_args) do |_, content|
          entry = Zip::File.open_buffer(content).find_entry(expected_data_filename)
          expect(entry).not_to be_nil
          expect(entry.get_input_stream.read).to eq(expected_content)
        end

        export_service.export_xml_organisations
      end

      it "returns the list with correct archive" do
        expect(export_service.export_xml_organisations).to eq({ expected_zip_filename.gsub(".zip", "") => start_time })
      end
    end

    context "and multiple organisations are available for export" do
      before do
        create(:organisation)
        create(:organisation)
      end

      it "generates an XML manifest file with the expected content within the ZIP file" do
        expected_content = replace_record_number(local_manifest_file.read, 2)
        expect(storage_service).to receive(:write_file).with(expected_zip_filename, any_args) do |_, content|
          entry = Zip::File.open_buffer(content).find_entry(expected_manifest_filename)
          expect(entry).not_to be_nil
          expect(entry.get_input_stream.read).to eq(expected_content)
        end

        export_service.export_xml_organisations
      end

      it "creates an export record in a database with correct time" do
        expect { export_service.export_xml_organisations }
          .to change(Export, :count).by(1)
        expect(Export.last.started_at).to be_within(2.seconds).of(start_time)
      end

      context "when this is the first export (full)" do
        it "returns a ZIP archive for the master manifest" do
          expect(export_service.export_xml_organisations).to eq({ expected_zip_filename.gsub(".zip", "").gsub(".zip", "") => start_time })
        end
      end

      context "and underlying data changes between getting the organisations and writting the manifest" do
        def remove_organisations(organisations)
          organisations.each(&:destroy)
          file = Tempfile.new
          doc = Nokogiri::XML("<forms/>")
          doc.write_xml_to(file, encoding: "UTF-8")
          file.rewind
          file
        end

        def create_fake_maifest
          file = Tempfile.new
          doc = Nokogiri::XML("<forms/>")
          doc.write_xml_to(file, encoding: "UTF-8")
          file.rewind
          file
        end

        it "maintains the same record number" do
          # rubocop:disable RSpec/SubjectStub
          allow(export_service).to receive(:build_export_xml) do |organisations|
            remove_organisations(organisations)
          end
          allow(export_service).to receive(:build_manifest_xml) do
            create_fake_maifest
          end

          expect(export_service).to receive(:build_manifest_xml).with(2)
          # rubocop:enable RSpec/SubjectStub
          export_service.export_xml_organisations
        end
      end

      context "when this is a second export (partial)" do
        before do
          start_time = Time.zone.local(2022, 6, 1)
          Export.new(started_at: start_time, collection: "organisations").save! # this should be organisation export
        end

        it "does not add any entry for the master manifest (no organisations)" do
          expect(export_service.export_xml_organisations).to eq({})
        end
      end
    end

    context "and a previous export has run the same day having organisations" do
      before do
        create(:organisation)
        export_service.export_xml_organisations
      end

      context "and we trigger another full update" do
        it "increments the base number" do
          export_service.export_xml_organisations(full_update: true)
          expect(Export.last.base_number).to eq(2)
        end

        it "resets the increment number" do
          export_service.export_xml_organisations(full_update: true)
          expect(Export.last.increment_number).to eq(1)
        end

        it "returns a correct archives list for manifest file" do
          expect(export_service.export_xml_organisations(full_update: true)).to eq({ "organisations_2024_2025_apr_mar_f0002_inc0001" => start_time })
        end

        it "generates a ZIP export file with the expected filename" do
          expect(storage_service).to receive(:write_file).with("organisations_2024_2025_apr_mar_f0002_inc0001.zip", any_args)
          export_service.export_xml_organisations(full_update: true)
        end
      end
    end

    context "and a previous export has run having no organisations" do
      before { export_service.export_xml_organisations }

      it "doesn't increment the manifest number by 1" do
        export_service.export_xml_organisations

        expect(Export.last.increment_number).to eq(1)
      end
    end

    context "and an organisation has been migrated since the previous partial export" do
      before do
        create(:organisation, updated_at: Time.zone.local(2022, 4, 27))
        create(:organisation, updated_at: Time.zone.local(2022, 4, 27))
        Export.create!(started_at: Time.zone.local(2022, 4, 26), base_number: 1, increment_number: 1)
      end

      it "generates an XML manifest file with the expected content within the ZIP file" do
        expected_content = replace_record_number(local_manifest_file.read, 2)
        expect(storage_service).to receive(:write_file).with(expected_zip_filename, any_args) do |_, content|
          entry = Zip::File.open_buffer(content).find_entry(expected_manifest_filename)
          expect(entry).not_to be_nil
          expect(entry.get_input_stream.read).to eq(expected_content)
        end

        expect(export_service.export_xml_organisations).to eq({ expected_zip_filename.gsub(".zip", "") => start_time })
      end
    end
  end
end
