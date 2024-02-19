require "rails_helper"
require "rake"

RSpec.describe "correct_noint_value" do
  describe ":correct_noint_value", type: :task do
    subject(:task) { Rake::Task["correct_noint_value"] }

    before do
      Rake.application.rake_require("tasks/correct_noint_value")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and there is a sales bulk upload with the fix needed" do
        let(:bulk_upload) { create(:bulk_upload, :sales, noint_fix_status: BulkUpload.noint_fix_statuses[:not_applied]) }

        before do
          bulk_upload.save!
        end

        it "updates the noint value on a log with noint = 2 where it was set to 2 on create" do
          log = create(:sales_log, :completed, noint: 2, bulk_upload:)

          task.invoke
          log.reload

          expect(log.noint).to be(1)
        end

        it "updates the noint value on a log with noint = 2 where it was set to 2 on create and other fields have since changed" do
          log = create(:sales_log, :in_progress, noint: 2, bulk_upload:)
          log.update!(status: Log.statuses[:completed])

          task.invoke
          log.reload

          expect(log.noint).to be(1)
        end

        it "does not update the noint value on a log that has noint = 1" do
          log = create(:sales_log, :completed, noint: 2, bulk_upload:)
          log.update!(noint: 1)

          task.invoke
          log.reload

          expect(log.noint).to be(1)
        end

        it "does not update the noint value on a log with noint = 2 where noint was nil on create" do
          log = create(:sales_log, :completed, noint: nil, bulk_upload:)
          log.update!(noint: 2)

          task.invoke
          log.reload

          expect(log.noint).to be(2)
        end

        it "updates the noint_fix_status value on the bulk upload" do
          task.invoke
          bulk_upload.reload

          expect(bulk_upload.noint_fix_status).to eq(BulkUpload.noint_fix_statuses[:applied])
        end
      end

      context "and there is a sales bulk upload with the fix marked as not needed" do
        let(:bulk_upload) { create(:bulk_upload, :sales, noint_fix_status: BulkUpload.noint_fix_statuses[:not_needed]) }

        before do
          bulk_upload.save!
        end

        it "does not update the noint values on logs" do
          log = create(:sales_log, :completed, noint: 2, bulk_upload:)

          task.invoke
          log.reload

          expect(log.noint).to be(2)
        end
      end
    end
  end
end
