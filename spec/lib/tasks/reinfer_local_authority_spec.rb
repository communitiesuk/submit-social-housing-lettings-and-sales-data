require "rails_helper"
require "rake"

RSpec.describe "reinfer_local_authority" do
  describe ":reinfer_local_authority", type: :task do
    subject(:task) { Rake::Task["reinfer_local_authority"] }

    before do
      Rake.application.rake_require("tasks/reinfer_local_authority")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and there is a general needs type lettings log with postcode and without LA" do
        let(:log) { create(:lettings_log, :completed, postcode_full: "AA1 1AA", status: "completed", startdate: Time.zone.local(2023, 4, 1)) }

        it "updates the la if it can be inferred" do
          log.la = nil
          log.save!(validate: false)
          task.invoke

          log.reload
          expect(log.la).to eq("E09000033")
          expect(log.status).to eq("completed")
        end

        it "does not update the la if it cannot be inferred and sets status to in_progress" do
          log.la = nil
          log.postcode_full = "B11AB"
          log.save!(validate: false)
          task.invoke

          log.reload
          expect(log.la).to be_nil
          expect(log.status).to eq("in_progress")
        end
      end

      context "and the lettings log has a validation error" do
        let(:log) { build(:lettings_log, :completed, postcode_full: "some fake postcode", la: nil, status: "completed", startdate: Time.zone.local(2023, 4, 1)) }

        it "logs invalid log ID" do
          log.save!(validate: false)
          expect(Rails.logger).to receive(:info).with("Invalid lettings log: #{log.id}")

          task.invoke
        end
      end

      context "and there is a sales log with postcode and without LA" do
        let(:log) { create(:sales_log, :completed, postcode_full: "AA1 1AA", status: "completed", saledate: Time.zone.local(2023, 4, 1)) }

        it "updates the la if it can be inferred" do
          log.la = nil
          log.save!(validate: false)
          task.invoke

          log.reload
          expect(log.la).to eq("E09000033")
          expect(log.status).to eq("completed")
        end

        it "does not update the la if it cannot be inferred and sets status to in_progress" do
          log.la = nil
          log.postcode_full = "B11AB"
          log.save!(validate: false)
          task.invoke

          log.reload
          expect(log.la).to be_nil
          expect(log.status).to eq("in_progress")
        end
      end

      context "and the sales log has a validation error" do
        let(:log) { build(:sales_log, :completed, postcode_full: "some fake postcode", la: nil, status: "completed", saledate: Time.zone.local(2023, 4, 1)) }

        it "logs invalid log ID" do
          log.save!(validate: false)
          expect(Rails.logger).to receive(:info).with("Invalid sales log: #{log.id}")

          task.invoke
        end
      end
    end
  end
end
