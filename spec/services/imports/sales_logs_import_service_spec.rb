require "rails_helper"

RSpec.describe Imports::SalesLogsImportService do
  subject(:sales_log_service) { described_class.new(storage_service, logger) }

  let(:storage_service) { instance_double(Storage::S3Service) }
  let(:logger) { instance_double(ActiveSupport::Logger) }

  let(:fixture_directory) { "spec/fixtures/imports/sales_logs" }

  let(:organisation) { FactoryBot.create(:organisation, old_visible_id: "1", provider_type: "PRP") }
  let(:managing_organisation) { FactoryBot.create(:organisation, old_visible_id: "2", provider_type: "PRP") }

  def open_file(directory, filename)
    File.open("#{directory}/#{filename}.xml")
  end

  before do
    WebMock.stub_request(:get, /api.postcodes.io\/postcodes\/GL519EX/)
           .to_return(status: 200, body: '{"status":200,"result":{"admin_district":"Westminster","codes":{"admin_district":"E09000033"}}}', headers: {})

    allow(Organisation).to receive(:find_by).and_return(nil)
    allow(Organisation).to receive(:find_by).with(old_visible_id: organisation.old_visible_id).and_return(organisation)
    allow(Organisation).to receive(:find_by).with(old_visible_id: managing_organisation.old_visible_id).and_return(managing_organisation)

    # Created by users
    FactoryBot.create(:user, old_user_id: "c3061a2e6ea0b702e6f6210d5c52d2a92612d2aa", organisation:)
    FactoryBot.create(:user, old_user_id: "e29c492473446dca4d50224f2bb7cf965a261d6f", organisation:)
  end

  context "when importing sales logs" do
    let(:remote_folder) { "sales_logs" }
    let(:sales_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }
    let(:sales_log_id2) { "166fc004-392e-47a8-acb8-1c018734882b" }
    let(:sales_log_id3) { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }
    let(:sales_log_id4) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

    before do
      # Stub the S3 file listing and download
      allow(storage_service).to receive(:list_files)
                                  .and_return(%W[#{remote_folder}/#{sales_log_id}.xml #{remote_folder}/#{sales_log_id2}.xml #{remote_folder}/#{sales_log_id3}.xml #{remote_folder}/#{sales_log_id4}.xml])
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{sales_log_id}.xml")
                                  .and_return(open_file(fixture_directory, sales_log_id), open_file(fixture_directory, sales_log_id))
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{sales_log_id2}.xml")
                                  .and_return(open_file(fixture_directory, sales_log_id2), open_file(fixture_directory, sales_log_id2))
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{sales_log_id3}.xml")
                                  .and_return(open_file(fixture_directory, sales_log_id3), open_file(fixture_directory, sales_log_id3))
      allow(storage_service).to receive(:get_file_io)
                                  .with("#{remote_folder}/#{sales_log_id4}.xml")
                                  .and_return(open_file(fixture_directory, sales_log_id4), open_file(fixture_directory, sales_log_id4))
    end

    it "successfully creates all sales logs" do
      expect(logger).not_to receive(:error)
      expect(logger).not_to receive(:warn)
      expect(logger).not_to receive(:info)
      expect { sales_log_service.create_logs(remote_folder) }
        .to change(SalesLog, :count).by(4)
    end

    it "only updates existing sales logs" do
      expect(logger).not_to receive(:error)
      expect(logger).not_to receive(:warn)
      expect(logger).to receive(:info).with(/Updating sales log/).exactly(4).times
      expect { 2.times { sales_log_service.create_logs(remote_folder) } }
        .to change(SalesLog, :count).by(4)
    end

    context "when there are status discrepancies" do
      let(:sales_log_id5) { "893ufj2s-lq77-42m4-rty6-ej09gh585uy1" }
      let(:sales_log_id6) { "5ybz29dj-l33t-k1l0-hj86-n4k4ma77xkcd" }
      let(:sales_log_file) { open_file(fixture_directory, sales_log_id5) }
      let(:sales_log_xml) { Nokogiri::XML(sales_log_file) }

      before do
        allow(storage_service).to receive(:get_file_io)
          .with("#{remote_folder}/#{sales_log_id5}.xml")
          .and_return(open_file(fixture_directory, sales_log_id5), open_file(fixture_directory, sales_log_id5))
        allow(storage_service).to receive(:get_file_io)
          .with("#{remote_folder}/#{sales_log_id6}.xml")
          .and_return(open_file(fixture_directory, sales_log_id6), open_file(fixture_directory, sales_log_id6))
      end

      it "the logger logs a warning with the sales log's old id/filename" do
        expect(logger).to receive(:warn).with(/is not completed/).once
        expect(logger).to receive(:warn).with(/sales log with old id:#{sales_log_id5} is incomplete but status should be complete/).once

        sales_log_service.send(:create_log, sales_log_xml)
      end

      it "on completion the ids of all logs with status discrepancies are logged in a warning" do
        allow(storage_service).to receive(:list_files)
                                  .and_return(%W[#{remote_folder}/#{sales_log_id5}.xml #{remote_folder}/#{sales_log_id6}.xml])
        expect(logger).to receive(:warn).with(/is not completed/).twice
        expect(logger).to receive(:warn).with(/is incomplete but status should be complete/).twice
        expect(logger).to receive(:warn).with(/The following sales logs had status discrepancies: \[893ufj2s-lq77-42m4-rty6-ej09gh585uy1, 5ybz29dj-l33t-k1l0-hj86-n4k4ma77xkcd\]/)

        sales_log_service.create_logs(remote_folder)
      end
    end
  end

  context "when importing a specific log" do
    let(:sales_log_file) { open_file(fixture_directory, sales_log_id) }
    let(:sales_log_xml) { Nokogiri::XML(sales_log_file) }

    context "and the organisation legacy ID does not exist" do
      let(:sales_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }

      before { sales_log_xml.at_xpath("//xmlns:OWNINGORGID").content = 99_999 }

      it "raises an exception" do
        expect { sales_log_service.send(:create_log, sales_log_xml) }
          .to raise_error(RuntimeError, "Organisation not found with legacy ID 99999")
      end
    end

    context "when the mortgage lender is set to an existing option" do
      let(:sales_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q34a").content = "halifax"
        allow(logger).to receive(:warn).and_return(nil)
      end

      it "correctly sets mortgage lender" do
        sales_log_service.send(:create_log, sales_log_xml)

        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log&.mortgagelender).to be(11)
      end
    end

    context "when the mortgage lender is set to a non existing option" do
      let(:sales_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

      before do
        sales_log_xml.at_xpath("//xmlns:Q34a").content = "something else"
        allow(logger).to receive(:warn).and_return(nil)
      end

      it "correctly sets mortgage lender and mortgage lender other" do
        sales_log_service.send(:create_log, sales_log_xml)

        sales_log = SalesLog.find_by(old_id: sales_log_id)
        expect(sales_log&.mortgagelender).to be(40)
        expect(sales_log&.mortgagelenderother).to eq("something else")
      end
    end

    context "with shared ownership type" do
      let(:sales_log_id) { "0ead17cb-1668-442d-898c-0d52879ff592" }

      it "successfully creates a completed shared ownership log" do
        allow(logger).to receive(:warn).and_return(nil)
        sales_log_service.send(:create_log, sales_log_xml)

        sales_log = SalesLog.find_by(old_id: sales_log_id)
        applicable_questions = sales_log.form.subsections.map { |s| s.applicable_questions(sales_log) }.flatten
        expect(applicable_questions.filter { |q| q.unanswered?(sales_log) }.map(&:id)).to be_empty
      end
    end

    context "with discounted ownership type" do
      let(:sales_log_id) { "0b4a68df-30cc-474a-93c0-a56ce8fdad3b" }

      it "successfully creates a completed discounted ownership log" do
        allow(logger).to receive(:warn).and_return(nil)
        sales_log_service.send(:create_log, sales_log_xml)

        sales_log = SalesLog.find_by(old_id: sales_log_id)
        applicable_questions = sales_log.form.subsections.map { |s| s.applicable_questions(sales_log) }.flatten
        expect(applicable_questions.filter { |q| q.unanswered?(sales_log) }.map(&:id)).to be_empty
      end
    end

    context "with outright sale type" do
      let(:sales_log_id) { "00d2343e-d5fa-4c89-8400-ec3854b0f2b4" }

      it "successfully creates a completed outright sale log" do
        allow(logger).to receive(:warn).and_return(nil)
        sales_log_service.send(:create_log, sales_log_xml)

        sales_log = SalesLog.find_by(old_id: sales_log_id)
        applicable_questions = sales_log.form.subsections.map { |s| s.applicable_questions(sales_log) }.flatten
        expect(applicable_questions.filter { |q| q.unanswered?(sales_log) }.map(&:id)).to be_empty
      end
    end
  end
end
