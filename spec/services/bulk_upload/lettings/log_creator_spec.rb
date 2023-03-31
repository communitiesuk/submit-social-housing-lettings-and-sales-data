require "rails_helper"

RSpec.describe BulkUpload::Lettings::LogCreator do
  subject(:service) { described_class.new(bulk_upload:, path:) }

  let(:owning_org) { create(:organisation, old_visible_id: 123) }
  let(:user) { create(:user, organisation: owning_org) }

  let(:bulk_upload) { create(:bulk_upload, :lettings, user:) }
  let(:path) { file_fixture("2022_23_lettings_bulk_upload.csv") }

  describe "#call" do
    context "when a valid csv with new log" do
      it "creates a new log" do
        expect { service.call }.to change(LettingsLog, :count)
      end

      it "create a log with pending status" do
        service.call
        expect(LettingsLog.last.status).to eql("pending")
      end

      it "associates log with bulk upload" do
        service.call

        log = LettingsLog.last
        expect(log.bulk_upload).to eql(bulk_upload)
        expect(bulk_upload.lettings_logs).to include(log)
      end
    end

    context "when a valid csv with several blank rows" do
      let(:file) { Tempfile.new }
      let(:path) { file.path }
      let(:log) { LettingsLog.new }

      before do
        file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind
      end

      it "ignores them and does not create the logs" do
        expect { service.call }.not_to change(LettingsLog, :count)
      end
    end

    context "when a valid csv with row with one invalid non setup field" do
      let(:file) { Tempfile.new }
      let(:path) { file.path }
      let(:log) do
        build(
          :lettings_log,
          :completed,
          renttype: 3,
          age1: 5,
          owning_organisation: owning_org,
          managing_organisation: owning_org,
          national: 18,
          waityear: 9,
          joint: 2,
          tenancy: 9,
          ppcodenk: 0,
        )
      end

      before do
        file.write(BulkUpload::LogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind
      end

      it "creates the log" do
        expect { service.call }.to change(LettingsLog, :count).by(1)
      end

      it "blanks invalid field" do
        service.call

        record = LettingsLog.last
        expect(record.age1).to be_blank
      end
    end

    context "when pre-creating logs" do
      subject(:service) { described_class.new(bulk_upload:, path:) }

      it "creates a new log" do
        expect { service.call }.to change(LettingsLog, :count)
      end

      it "creates a log with correct states" do
        service.call

        last_log = LettingsLog.last

        expect(last_log.status).to eql("pending")
        expect(last_log.status_cache).to eql("completed")
      end
    end

    context "when valid csv with existing log" do
      xit "what should happen?"
    end
  end
end
