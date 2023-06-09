require "rails_helper"

RSpec.describe BulkUpload::Sales::LogCreator do
  subject(:service) { described_class.new(bulk_upload:, path:) }

  let(:owning_org) { create(:organisation, old_visible_id: 123) }
  let(:user) { create(:user, organisation: owning_org) }

  let(:bulk_upload) { create(:bulk_upload, :sales, user:) }
  let(:path) { file_fixture("completed_2022_23_sales_bulk_upload.csv") }

  describe "#call" do
    around do |example|
      Timecop.freeze(Time.zone.local(2023, 2, 22)) do
        Singleton.__init__(FormHandler)
        example.run
      end
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "when a valid csv with new log" do
      it "creates a new log" do
        expect { service.call }.to change(SalesLog, :count)
      end

      it "create a log with pending status" do
        service.call
        expect(SalesLog.last.status).to eql("pending")
      end

      it "associates log with bulk upload" do
        service.call

        log = SalesLog.last
        expect(log.bulk_upload).to eql(bulk_upload)
        expect(bulk_upload.sales_logs).to include(log)
      end
    end

    context "when a valid csv with several blank rows" do
      let(:file) { Tempfile.new }
      let(:path) { file.path }
      let(:log) { SalesLog.new }

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind
      end

      it "ignores them and does not create the logs" do
        expect { service.call }.not_to change(SalesLog, :count)
      end
    end

    context "when a valid csv with row with one invalid non setup field" do
      let(:file) { Tempfile.new }
      let(:path) { file.path }
      let(:log) do
        build(
          :sales_log,
          :completed,
          age1: 5,
          owning_organisation: owning_org,
        )
      end

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind
      end

      it "creates the log" do
        expect { service.call }.to change(SalesLog, :count).by(1)
      end

      it "blanks invalid field" do
        service.call

        record = SalesLog.last
        expect(record.age1).to be_blank
      end
    end

    context "when a valid csv with row with compound errors on non setup field" do
      let(:file) { Tempfile.new }
      let(:path) { file.path }
      let(:log) do
        build(
          :sales_log,
          :completed,
          ownershipsch: 2,
          pcodenk: 0,
          ppcodenk: 0,
          postcode_full: "AA11AA",
          ppostcode_full: "BB22BB",
        )
      end

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind
      end

      it "creates the log" do
        expect { service.call }.to change(SalesLog, :count).by(1)
      end

      it "blanks invalid field" do
        service.call

        record = SalesLog.last
        expect(record.pcodenk).to be_blank
        expect(record.postcode_full).to be_blank
        expect(record.ppcodenk).to be_blank
        expect(record.ppostcode_full).to be_blank
      end
    end

    context "when pre-creating logs" do
      subject(:service) { described_class.new(bulk_upload:, path:) }

      it "creates a new log" do
        expect { service.call }.to change(SalesLog, :count)
      end

      it "creates a log with correct states" do
        service.call

        last_log = SalesLog.last

        expect(last_log.status).to eql("pending")
        expect(last_log.status_cache).to eql("completed")
      end
    end

    context "when valid csv with existing log" do
      xit "what should happen?"
    end

    context "with a valid csv and soft validations" do
      let(:file) { Tempfile.new }
      let(:path) { file.path }
      let(:log) do
        build(
          :sales_log,
          :completed,
          age1: 30,
          age1_known: 0,
          ecstat1: 5,
          owning_organisation: owning_org,
          created_by: user,
        )
      end

      before do
        file.write(BulkUpload::SalesLogToCsv.new(log:, col_offset: 0).to_2022_csv_row)
        file.rewind
      end

      it "creates a new log" do
        expect { service.call }.to change(SalesLog, :count)
      end

      it "creates a log with pending status" do
        service.call
        expect(SalesLog.last.status).to eql("pending")
      end

      it "does not set unanswered soft validations" do
        service.call

        log = SalesLog.last
        expect(log.age1).to be(30)
        expect(log.ecstat1).to be(5)
        expect(log.retirement_value_check).to be(nil)
      end
    end
  end
end
