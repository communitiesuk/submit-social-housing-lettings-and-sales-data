require "rails_helper"
require "rake"

RSpec.describe "correct_rent_type_value" do
  describe ":correct_rent_type_value", type: :task do
    subject(:task) { Rake::Task["correct_rent_type_value"] }

    before do
      Rake.application.rake_require("tasks/correct_rent_type_value")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and rent_type is 1" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, year: 2024, rent_type_fix_status: BulkUpload.rent_type_fix_statuses[:not_applied]) }
        let(:bulk_upload_2023) { create(:bulk_upload, :lettings, year: 2023, rent_type_fix_status: BulkUpload.rent_type_fix_statuses[:not_applied]) }

        before do
          bulk_upload.save!
        end

        it "updates the rent_type value on a log where it was set to 1 on create" do
          log = create(:lettings_log, :completed, rent_type: 1, bulk_upload:)
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.rent_type).to be(0)
          expect(log.status).to eq("completed")
          expect(log.updated_at).not_to eq(initial_updated_at)
          expect(bulk_upload.reload.rent_type_fix_status).to eq(BulkUpload.rent_type_fix_statuses[:applied])
        end

        it "updates the rent_type value on a pending log where it was set to 1 on create" do
          log = build(:lettings_log, :completed, rent_type: 1, bulk_upload:, status: "pending")
          log.skip_update_status = true
          log.save!
          initial_updated_at = log.updated_at
          expect(log.status).to eq("pending")

          task.invoke
          log.reload

          expect(log.rent_type).to be(0)
          expect(log.status).to eq("pending")
          expect(log.updated_at).not_to eq(initial_updated_at)
          expect(bulk_upload.reload.rent_type_fix_status).to eq(BulkUpload.rent_type_fix_statuses[:applied])
        end

        it "updates the rent_type value on a deleted log where it was set to 1 on create" do
          log = create(:lettings_log, :completed, rent_type: 1, bulk_upload:, discarded_at: Time.zone.yesterday)
          initial_updated_at = log.updated_at
          expect(log.status).to eq("deleted")

          task.invoke
          log.reload

          expect(log.rent_type).to be(0)
          expect(log.status).to eq("deleted")
          expect(log.updated_at).not_to eq(initial_updated_at)
          expect(bulk_upload.reload.rent_type_fix_status).to eq(BulkUpload.rent_type_fix_statuses[:applied])
        end

        it "updates the rent_type value on a log where it was set to 1 on create and other fields have since changed" do
          log = create(:lettings_log, :completed, rent_type: 1, bulk_upload:)
          log.update!(tenancycode: "abc")
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.rent_type).to be(0)
          expect(log.status).to eq("completed")
          expect(log.updated_at).not_to eq(initial_updated_at)
          expect(bulk_upload.reload.rent_type_fix_status).to eq(BulkUpload.rent_type_fix_statuses[:applied])
        end

        it "does not update the rent_type value on a log if it has since been changed" do
          log = create(:lettings_log, :completed, rent_type: 1, bulk_upload:)
          log.update!(rent_type: 0)
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.rent_type).to be(0)
          expect(log.status).to eq("completed")
          expect(log.updated_at).to eq(initial_updated_at)
        end

        it "does not update the rent_type value on a 2023 log turned 2024" do
          log = build(:lettings_log, :completed, startdate: Time.zone.local(2023, 6, 6), rent_type: 1, bulk_upload: bulk_upload_2023)
          log.save!(validate: false)
          log.address_line1_input = log.address_line1
          log.postcode_full_input = log.postcode_full
          log.nationality_all_group = 826
          log.uprn = "10033558653"
          log.uprn_selection = 1
          log.startdate = Time.zone.today
          log.save!

          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.rent_type).to be(1)
          expect(log.updated_at).to eq(initial_updated_at)
        end

        it "does not update and logs error if a validation triggers" do
          log = build(:lettings_log, :completed, startdate: Time.zone.local(2021, 6, 6), rent_type: 1, bulk_upload:)
          log.save!(validate: false)
          initial_updated_at = log.updated_at

          expect(Rails.logger).to receive(:error).with(/Log #{log.id} rent_type could not be updated from 1 to 0. Error: /)
          task.invoke
          log.reload

          expect(log.rent_type).to be(1)
          expect(log.updated_at).to eq(initial_updated_at)
        end

        context "when the rent_type_fix_status is not_needed" do
          let(:bulk_upload) { create(:bulk_upload, :lettings, year: 2024, rent_type_fix_status: BulkUpload.rent_type_fix_statuses[:not_needed]) }

          before do
            bulk_upload.save!
          end

          it "does not update the rent_type values on logs" do
            log = create(:lettings_log, :completed, rent_type: 1, bulk_upload:)
            initial_updated_at = log.updated_at

            task.invoke
            log.reload

            expect(log.rent_type).to be(1)
            expect(log.updated_at).to eq(initial_updated_at)
            expect(bulk_upload.reload.rent_type_fix_status).to eq(BulkUpload.rent_type_fix_statuses[:not_needed])
          end
        end
      end

      context "and rent_type is 2" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, year: 2024, rent_type_fix_status: BulkUpload.rent_type_fix_statuses[:not_applied]) }
        let(:bulk_upload_2023) { create(:bulk_upload, :lettings, year: 2023, rent_type_fix_status: BulkUpload.rent_type_fix_statuses[:not_applied]) }

        before do
          bulk_upload.save!
        end

        it "updates the rent_type value on a log where it was set to 2 on create" do
          log = create(:lettings_log, :completed, rent_type: 2, bulk_upload:)
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.rent_type).to be(1)
          expect(log.status).to eq("completed")
          expect(log.updated_at).not_to eq(initial_updated_at)
        end

        it "updates the rent_type value on a pending log where it was set to 2 on create" do
          log = build(:lettings_log, :completed, rent_type: 2, bulk_upload:, status: "pending")
          log.skip_update_status = true
          log.save!
          initial_updated_at = log.updated_at
          expect(log.status).to eq("pending")

          task.invoke
          log.reload

          expect(log.rent_type).to be(1)
          expect(log.status).to eq("pending")
          expect(log.updated_at).not_to eq(initial_updated_at)
        end

        it "updates the rent_type value on a deleted log where it was set to 2 on create" do
          log = create(:lettings_log, :completed, rent_type: 2, bulk_upload:, discarded_at: Time.zone.yesterday)
          initial_updated_at = log.updated_at
          expect(log.status).to eq("deleted")

          task.invoke
          log.reload

          expect(log.rent_type).to be(1)
          expect(log.status).to eq("deleted")
          expect(log.updated_at).not_to eq(initial_updated_at)
        end

        it "updates the rent_type value on a log where it was set to 2 on create and other fields have since changed" do
          log = create(:lettings_log, :completed, rent_type: 2, bulk_upload:)
          log.update!(tenancycode: "abc")
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.rent_type).to be(1)
          expect(log.status).to eq("completed")
          expect(log.updated_at).not_to eq(initial_updated_at)
        end

        it "does not update the rent_type value on a log if it has since been changed" do
          log = create(:lettings_log, :completed, rent_type: 2, bulk_upload:)
          log.update!(rent_type: 0)
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.rent_type).to be(0)
          expect(log.status).to eq("completed")
          expect(log.updated_at).to eq(initial_updated_at)
        end

        it "does not update the rent_type value on a 2023 log turned 2024" do
          log = build(:lettings_log, :completed, startdate: Time.zone.local(2023, 6, 6), rent_type: 2, bulk_upload: bulk_upload_2023)
          log.save!(validate: false)
          log.address_line1_input = log.address_line1
          log.postcode_full_input = log.postcode_full
          log.nationality_all_group = 826
          log.uprn = "10033558653"
          log.uprn_selection = 1
          log.startdate = Time.zone.today
          log.save!

          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.rent_type).to be(2)
          expect(log.updated_at).to eq(initial_updated_at)
        end

        it "does not update and logs error if a validation triggers" do
          log = build(:lettings_log, :completed, startdate: Time.zone.local(2021, 6, 6), rent_type: 2, bulk_upload:)
          log.save!(validate: false)
          initial_updated_at = log.updated_at

          expect(Rails.logger).to receive(:error).with(/Log #{log.id} rent_type could not be updated from 2 to 1. Error: /)
          task.invoke
          log.reload

          expect(log.rent_type).to be(2)
          expect(log.updated_at).to eq(initial_updated_at)
        end
      end
    end
  end
end
