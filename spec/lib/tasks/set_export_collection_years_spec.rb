require "rails_helper"
require "rake"

RSpec.describe "set_export_collection_years" do
  describe ":set_export_collection_years", type: :task do
    subject(:task) { Rake::Task["set_export_collection_years"] }

    before do
      Rake.application.rake_require("tasks/set_export_collection_years")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:lettings_export_2023) { Export.create(collection: "2023", year: nil, started_at: Time.zone.now) }
      let!(:lettings_export_2024) { Export.create(collection: "2024", year: nil, started_at: Time.zone.now) }
      let!(:updated_lettings_export) { Export.create(collection: "lettings", year: 2023, started_at: Time.zone.now) }
      let!(:organisations_export) { Export.create(collection: "organisations", year: nil, started_at: Time.zone.now) }
      let!(:users_export) { Export.create(collection: "users", year: nil, started_at: Time.zone.now) }

      it "correctly updates collection years" do
        task.invoke

        expect(lettings_export_2023.reload.collection).to eq("lettings")
        expect(lettings_export_2023.year).to eq(2023)

        expect(lettings_export_2024.reload.collection).to eq("lettings")
        expect(lettings_export_2024.year).to eq(2024)

        expect(updated_lettings_export.reload.collection).to eq("lettings")
        expect(updated_lettings_export.year).to eq(2023)

        expect(organisations_export.reload.collection).to eq("organisations")
        expect(organisations_export.year).to eq(nil)

        expect(users_export.reload.collection).to eq("users")
        expect(users_export.year).to eq(nil)
      end
    end
  end
end
