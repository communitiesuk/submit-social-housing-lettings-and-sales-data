require "rails_helper"
require "rake"

RSpec.describe "set_log_validation_collection_year" do
  describe ":set_log_validation_collection_year", type: :task do
    subject(:task) { Rake::Task["set_log_validation_collection_year"] }

    before do
      Rake.application.rake_require("tasks/set_log_validation_collection_year")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:user) { create(:user) }

      context "and version whodunnit exists for create" do
        let!(:log_validation_2023) { LogValidation.create(from: Time.zone.local(2023, 4, 1), to: Time.zone.local(2024, 4, 1)) }
        let!(:log_validation_2024) { LogValidation.create(from: Time.zone.local(2024, 4, 1), to: Time.zone.local(2025, 4, 1)) }

        it "sets collection_year" do
          task.invoke
          expect(log_validation_2023.reload.collection_year).to eq("2023/2024")
          expect(log_validation_2024.reload.collection_year).to eq("2024/2025")
        end
      end
    end
  end
end
