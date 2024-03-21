require "rails_helper"
require "rake"

RSpec.describe "correct_renewal_postcodes" do
  describe ":correct_renewal_postcodes", type: :task do
    subject(:task) { Rake::Task["correct_renewal_postcodes"] }

    before do
      Rake.application.rake_require("tasks/correct_renewal_postcodes")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and there there is a renewal lettings log with different previous postcode" do
        let(:log) { create(:lettings_log, :completed, postcode_full: "SW1A 1AA", ppostcode_full: "AA1 1AA") }

        before do
          log.renewal = 1
          log.values_updated_at = nil
          log.save!(validate: false)
        end

        it "updates the previous postcode and reexports the log" do
          expect(log.ppostcode_full).to eq("AA1 1AA")

          task.invoke
          log.reload

          expect(log.ppostcode_full).to eq("SW1A 1AA")
          expect(log.values_updated_at).not_to eq(nil)
        end
      end

      context "and there there is a non renewal lettings log with different previous postcode" do
        let(:log) { create(:lettings_log, :completed, postcode_full: "SW1A 1AA", ppostcode_full: "AA1 1AA") }

        before do
          log.renewal = 0
          log.values_updated_at = nil
          log.save!(validate: false)
        end

        it "does not update and reexport the previous postcode" do
          expect(log.ppostcode_full).to eq("AA1 1AA")

          task.invoke
          log.reload

          expect(log.ppostcode_full).to eq("AA1 1AA")
          expect(log.values_updated_at).to eq(nil)
        end
      end

      context "and there there is a renewal lettings log with missing previous postcode" do
        let(:log) { create(:lettings_log, :completed, postcode_full: "SW1A 1AA", ppostcode_full: nil) }

        before do
          log.renewal = 1
          log.values_updated_at = nil
          log.save!(validate: false)
        end

        it "updates the previous postcode and reexports the log" do
          expect(log.ppostcode_full).to eq(nil)

          task.invoke
          log.reload

          expect(log.ppostcode_full).to eq("SW1A 1AA")
          expect(log.values_updated_at).not_to eq(nil)
        end
      end

      context "and there there is a renewal lettings log without postcode" do
        let(:log) { create(:lettings_log, :completed, postcode_known: 0, postcode_full: nil, ppostcode_full: "AA1 1AA") }

        before do
          log.renewal = 1
          log.values_updated_at = nil
          log.save!(validate: false)
        end

        it "clears the previous postcode and reexports the log" do
          expect(log.ppostcode_full).to eq("AA1 1AA")

          task.invoke
          log.reload

          expect(log.ppostcode_full).to eq(nil)
          expect(log.values_updated_at).not_to eq(nil)
        end
      end

      context "and there is a renewal lettings log with same postcodes" do
        let(:log) { create(:lettings_log, :completed, postcode_full: "AA1 1AA", ppostcode_full: "AA1 1AA") }

        before do
          log.renewal = 1
          log.values_updated_at = nil
          log.save!(validate: false)
        end

        it "does not update the previous postcode and does not re-export" do
          expect(log.ppostcode_full).to eq("AA1 1AA")

          task.invoke
          log.reload

          expect(log.ppostcode_full).to eq("AA1 1AA")
          expect(log.values_updated_at).to eq(nil)
        end
      end

      context "and there is a renewal lettings log with same nil postcodes" do
        let(:log) { create(:lettings_log, :completed, postcode_known: 0, la: "E07000223", prevloc: "E07000223", postcode_full: nil, ppostcode_full: nil) }

        before do
          log.renewal = 1
          log.values_updated_at = nil
          log.save!(validate: false)
        end

        it "does not update the previous postcode and does not re-export" do
          expect(log.ppostcode_full).to eq(nil)

          task.invoke
          log.reload

          expect(log.ppostcode_full).to eq(nil)
          expect(log.values_updated_at).to eq(nil)
        end
      end

      context "and there is a renewal lettings log with same nil postcodes and different la" do
        let(:log) { create(:lettings_log, :completed, postcode_known: 0, postcode_full: nil, la: "E07000223", ppostcode_full: nil, prevloc: "E07000026") }

        before do
          log.renewal = 1
          log.values_updated_at = nil
          log.save!(validate: false)
        end

        it "updates the previous la and reexports the log" do
          expect(log.ppostcode_full).to eq(nil)

          task.invoke
          log.reload

          expect(log.prevloc).to eq("E07000223")
          expect(log.values_updated_at).not_to eq(nil)
        end
      end

      context "and there is a renewal lettings log with same nil postcodes, la not nil and prevloc nil" do
        let(:log) { create(:lettings_log, :completed, postcode_known: 0, postcode_full: nil, la: "E07000223", ppostcode_full: nil, previous_la_known: 0, prevloc: nil) }

        before do
          log.renewal = 1
          log.values_updated_at = nil
          log.save!(validate: false)
        end

        it "updates the previous la and reexports the log" do
          expect(log.ppostcode_full).to eq(nil)

          task.invoke
          log.reload

          expect(log.prevloc).to eq("E07000223")
          expect(log.values_updated_at).not_to eq(nil)
        end
      end

      context "and there is a renewal lettings log with same nil postcodes, la nil and prevloc not nil" do
        let(:log) { create(:lettings_log, :completed, postcode_known: 0, postcode_full: nil, la: nil, ppostcode_full: nil, prevloc: "E07000223") }

        before do
          log.renewal = 1
          log.values_updated_at = nil
          log.save!(validate: false)
        end

        it "updates the previous la and reexports the log" do
          expect(log.ppostcode_full).to eq(nil)
          expect(log.prevloc).to eq("E07000223")

          task.invoke
          log.reload

          expect(log.prevloc).to eq(nil)
          expect(log.values_updated_at).not_to eq(nil)
        end
      end

      context "and there is a renewal lettings log from closed collection year" do
        let(:log) { create(:lettings_log, :completed, postcode_full: "AA1 1AA", ppostcode_full: nil) }

        before do
          log.renewal = 1
          log.values_updated_at = nil
          log.startdate = Time.zone.local(2022, 4, 4)
          log.save!(validate: false)
        end

        it "does not update the previous postcode and does not re-export" do
          expect(log.ppostcode_full).to eq(nil)

          task.invoke
          log.reload

          expect(log.ppostcode_full).to eq(nil)
          expect(log.values_updated_at).to eq(nil)
        end
      end
    end
  end
end
