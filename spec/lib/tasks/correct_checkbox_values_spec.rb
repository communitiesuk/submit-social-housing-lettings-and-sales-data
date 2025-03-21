require "rails_helper"
require "rake"

RSpec.describe "correct_checkbox_values" do
  describe ":correct_checkbox_values", type: :task do
    subject(:task) { Rake::Task["correct_checkbox_values"] }

    let(:organisation) { create(:organisation, rent_periods: [2]) }
    let(:user) { create(:user, organisation:) }

    before do
      Timecop.return
      Rake.application.rake_require("tasks/correct_checkbox_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and any of the reasonable_preference_reason options are 1" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, year: 2024, rent_type_fix_status: BulkUpload.rent_type_fix_statuses[:not_applied]) }

        it "sets the remaining options to 0" do
          log = build(:lettings_log, :completed, reasonpref: 1, rp_homeless: 1, rp_hardship: nil, rp_medwel: nil, rp_insan_unsat: nil, rp_dontknow: nil,
                                                 bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.updated_at).not_to eq(initial_updated_at)
          expect(log.status).to eq("completed")
          expect(log.rp_homeless).to be(1)
          expect(log.rp_hardship).to be(0)
          expect(log.rp_medwel).to be(0)
          expect(log.rp_insan_unsat).to be(0)
          expect(log.rp_dontknow).to be(0)
        end

        it "updates the reasonable preference reason values on a pending log" do
          log = build(:lettings_log, :completed, status: "pending", reasonpref: 1, rp_homeless: 1, rp_hardship: nil, rp_medwel: 1, rp_insan_unsat: nil, rp_dontknow: nil, bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at
          expect(log.status).to eq("pending")

          task.invoke
          log.reload
          expect(log.rp_homeless).to be(1)
          expect(log.rp_hardship).to be(0)
          expect(log.rp_medwel).to be(1)
          expect(log.rp_insan_unsat).to be(0)
          expect(log.rp_dontknow).to be(0)
          expect(log.status).to eq("pending")
          expect(log.updated_at).not_to eq(initial_updated_at)
        end

        it "does not update logs if all unselected reasonable preference reason are alredy 0" do
          log = build(:lettings_log, :completed, reasonpref: 1, rp_homeless: 0, rp_hardship: 1, rp_medwel: 0, rp_insan_unsat: 0, rp_dontknow: 0, bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at
          expect(log.status).to eq("completed")

          task.invoke
          log.reload

          expect(log.status).to eq("completed")
          expect(log.updated_at).to eq(initial_updated_at)
        end

        it "updates the reasonable preference reason values if some of the checkbox values are nil" do
          log = build(:lettings_log, :completed, status: "pending", reasonpref: 1, rp_homeless: 0, rp_hardship: nil, rp_medwel: 1, rp_insan_unsat: 0, rp_dontknow: 0, bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at
          expect(log.status).to eq("pending")

          task.invoke
          log.reload
          expect(log.rp_homeless).to be(0)
          expect(log.rp_hardship).to be(0)
          expect(log.rp_medwel).to be(1)
          expect(log.rp_insan_unsat).to be(0)
          expect(log.rp_dontknow).to be(0)
          expect(log.status).to eq("pending")
          expect(log.updated_at).not_to eq(initial_updated_at)
        end

        it "does not update the reasonable preference reason values on a 2023 log" do
          log = build(:lettings_log, :completed, startdate: Time.zone.local(2023, 6, 6), reasonpref: 1, rp_homeless: 0, rp_hardship: nil, rp_medwel: 1, rp_insan_unsat: 0, rp_dontknow: 0, bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.updated_at).to eq(initial_updated_at)
        end

        it "does not update and logs error if a validation triggers" do
          log = build(:lettings_log, :completed, postcode_full: "0", reasonpref: 1, rp_homeless: 0, rp_hardship: nil, rp_medwel: 1, rp_insan_unsat: 0, rp_dontknow: 0, bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.updated_at).to eq(initial_updated_at)
        end
      end

      context "and any of the illness_type options are 1" do
        let(:bulk_upload) { create(:bulk_upload, :lettings, year: 2024, rent_type_fix_status: BulkUpload.rent_type_fix_statuses[:not_applied]) }

        it "sets the remaining options to 0" do
          log = build(:lettings_log, :completed, illness: 1, illness_type_1: 1, illness_type_2: nil, illness_type_3: nil, illness_type_4: nil, illness_type_5: nil, illness_type_6: nil, illness_type_7: nil, illness_type_8: nil, illness_type_9: nil, illness_type_10: nil,
                                                 bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.updated_at).not_to eq(initial_updated_at)
          expect(log.status).to eq("completed")
          expect(log.illness_type_1).to be(1)
          expect(log.illness_type_2).to be(0)
          expect(log.illness_type_3).to be(0)
          expect(log.illness_type_4).to be(0)
          expect(log.illness_type_5).to be(0)
          expect(log.illness_type_6).to be(0)
          expect(log.illness_type_7).to be(0)
          expect(log.illness_type_8).to be(0)
          expect(log.illness_type_9).to be(0)
          expect(log.illness_type_10).to be(0)
        end

        it "updates the reasonable preference reason values on a pending log" do
          log = build(:lettings_log, :completed, status: "pending", illness: 1, illness_type_1: 1, illness_type_2: nil, illness_type_3: nil, illness_type_4: nil, illness_type_5: nil, illness_type_6: nil, illness_type_7: nil, illness_type_8: nil, illness_type_9: nil, illness_type_10: nil, bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at
          expect(log.status).to eq("pending")

          task.invoke
          log.reload
          expect(log.illness_type_1).to be(1)
          expect(log.illness_type_2).to be(0)
          expect(log.illness_type_3).to be(0)
          expect(log.illness_type_4).to be(0)
          expect(log.illness_type_5).to be(0)
          expect(log.illness_type_6).to be(0)
          expect(log.illness_type_7).to be(0)
          expect(log.illness_type_8).to be(0)
          expect(log.illness_type_9).to be(0)
          expect(log.illness_type_10).to be(0)
          expect(log.status).to eq("pending")
          expect(log.updated_at).not_to eq(initial_updated_at)
        end

        it "does not update logs if all unselected reasonable preference reason are alredy 0" do
          log = build(:lettings_log, :completed, illness: 1, illness_type_1: 0, illness_type_2: 1, illness_type_3: 0, illness_type_4: 0, illness_type_5: 0, illness_type_6: 0, illness_type_7: 0, illness_type_8: 0, illness_type_9: 0, illness_type_10: 0, bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at
          expect(log.status).to eq("completed")

          task.invoke
          log.reload

          expect(log.status).to eq("completed")
          expect(log.updated_at).to eq(initial_updated_at)
        end

        it "updates the reasonable preference reason values if some of the checkbox values are nil" do
          log = build(:lettings_log, :completed, status: "pending", illness: 1, illness_type_1: 0, illness_type_2: nil, illness_type_3: 1, illness_type_4: 0, illness_type_5: 0, illness_type_6: nil, illness_type_7: nil, illness_type_8: nil, illness_type_9: nil, illness_type_10: nil, bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at
          expect(log.status).to eq("pending")

          task.invoke
          log.reload
          expect(log.illness_type_1).to be(0)
          expect(log.illness_type_2).to be(0)
          expect(log.illness_type_3).to be(1)
          expect(log.illness_type_4).to be(0)
          expect(log.illness_type_5).to be(0)
          expect(log.illness_type_6).to be(0)
          expect(log.illness_type_7).to be(0)
          expect(log.illness_type_8).to be(0)
          expect(log.illness_type_9).to be(0)
          expect(log.illness_type_10).to be(0)
          expect(log.status).to eq("pending")
          expect(log.updated_at).not_to eq(initial_updated_at)
        end

        it "does not update the reasonable preference reason values on a 2023 log" do
          log = build(:lettings_log, :completed, startdate: Time.zone.local(2023, 6, 6), illness: 1, illness_type_1: 0, illness_type_2: nil, illness_type_3: 1, illness_type_4: 0, illness_type_5: 0, illness_type_6: nil, illness_type_7: nil, illness_type_8: nil, illness_type_9: nil, illness_type_10: nil, bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.updated_at).to eq(initial_updated_at)
        end

        it "does not update and logs error if a validation triggers" do
          log = build(:lettings_log, :completed, postcode_full: "0", illness: 1, illness_type_1: 0, illness_type_2: nil, illness_type_3: 1, illness_type_4: 0, illness_type_5: 0, illness_type_6: nil, illness_type_7: nil, illness_type_8: nil, illness_type_9: nil, illness_type_10: nil, bulk_upload:, assigned_to: user)
          log.save!(validate: false)
          initial_updated_at = log.updated_at

          task.invoke
          log.reload

          expect(log.updated_at).to eq(initial_updated_at)
        end
      end
    end
  end
end
