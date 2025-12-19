require "rails_helper"

RSpec.describe BulkUpload::Lettings::LogCreator do
  subject(:service) { described_class.new(bulk_upload:, path: "") }

  let(:owning_org) { create(:organisation, old_visible_id: 123, rent_periods: [2]) }
  let(:user) { create(:user, organisation: owning_org) }

  let(:bulk_upload) { create(:bulk_upload, :lettings, user:, year: 2024) }
  let(:csv_parser) { instance_double(BulkUpload::Lettings::Year2024::CsvParser) }
  let(:row_parser) { instance_double(BulkUpload::Lettings::Year2024::RowParser) }
  let(:log) { build(:lettings_log, :completed, assigned_to: user, owning_organisation: owning_org, managing_organisation: owning_org) }

  before do
    allow(BulkUpload::Lettings::Year2024::CsvParser).to receive(:new).and_return(csv_parser)
    allow(csv_parser).to receive(:row_parsers).and_return([row_parser])
    allow(row_parser).to receive(:log).and_return(log)
    allow(row_parser).to receive(:bulk_upload=).and_return(true)
    allow(row_parser).to receive(:valid?).and_return(true)
    allow(row_parser).to receive(:blank_row?).and_return(false)
  end

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

      it "sets the creation method" do
        service.call

        expect(LettingsLog.last.creation_method_bulk_upload?).to be true
      end
    end

    context "when a valid csv with several blank rows" do
      before do
        allow(row_parser).to receive(:blank_row?).and_return(true)
      end

      it "ignores them and does not create the logs" do
        expect { service.call }.not_to change(LettingsLog, :count)
      end
    end

    context "when a valid csv with row with one invalid non setup field" do
      let(:log) do
        build(
          :lettings_log,
          :completed,
          age1_known: 0,
          age1: 5,
          owning_organisation: owning_org,
          managing_organisation: owning_org,
          assigned_to: user,
        )
      end

      it "creates the log" do
        expect { service.call }.to change(LettingsLog, :count).by(1)
      end

      it "blanks invalid field" do
        allow(row_parser).to receive(:valid?).and_return(false)
        service.call

        record = LettingsLog.last
        expect(record.age1).to be_blank
      end
    end

    context "when a valid csv with row with compound errors on non setup field" do
      let(:log) do
        build(
          :lettings_log,
          :completed,
          earnings: 0,
          incfreq: 1,
        )
      end

      it "creates the log" do
        expect { service.call }.to change(LettingsLog, :count).by(1)
      end

      it "blanks invalid fields" do
        allow(row_parser).to receive(:valid?).and_return(false)
        service.call

        record = LettingsLog.last
        expect(record.earnings).to be_blank
        expect(record.incfreq).to be_blank
      end
    end

    context "when pre-creating logs" do
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

    context "with a valid csv and soft validations" do
      let(:log) do
        build(
          :lettings_log,
          :completed,
          age1: 22,
          age1_known: 0,
          ecstat1: 5,
          owning_organisation: owning_org,
          managing_organisation: owning_org,
          assigned_to: user,
        )
      end

      it "creates a new log" do
        expect { service.call }.to change(LettingsLog, :count)
      end

      it "creates a log with pending status" do
        service.call
        expect(LettingsLog.last.status).to eql("pending")
      end

      it "does not set unanswered soft validations" do
        service.call

        log = LettingsLog.last
        expect(log.age1).to be(22)
        expect(log.ecstat1).to be(5)
        expect(log.retirement_value_check).to be(nil)
      end
    end
  end
end
