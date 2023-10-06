require "rails_helper"
require "rake"
RSpec.describe "correct_illness" do
  describe ":create_illness_csv", type: :task do
    subject(:task) { Rake::Task["correct_illness:create_illness_csv"] }

    before do
      organisation.users.destroy_all
      Rake.application.rake_require("tasks/correct_illness_from_csv")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:organisation) { create(:organisation, name: "test organisation") }

      context "and organisation ID is provided" do
        it "enqueues the job with correct organisation" do
          expect { task.invoke(organisation.id) }.to enqueue_job(CreateIllnessCsvJob).with(organisation)
        end

        it "prints out the jobs enqueued" do
          expect(Rails.logger).to receive(:info).with(nil)
          expect(Rails.logger).to receive(:info).with("Creating illness CSV for test organisation")
          task.invoke(organisation.id)
        end
      end

      context "when organisation with given ID cannot be found" do
        it "prints out error" do
          expect(Rails.logger).to receive(:error).with("Organisation with ID fake not found")
          task.invoke("fake")
        end
      end

      context "when organisation ID is not given" do
        it "raises an error" do
          expect { task.invoke }.to raise_error(RuntimeError, "Usage: rake correct_illness:create_illness_csv['organisation_id']")
        end
      end
    end
  end
end
