require "rails_helper"
require "rake"

RSpec.describe "correct_location_admin_district" do
  describe ":correct_location_admin_district", type: :task do
    subject(:task) { Rake::Task["correct_location_admin_district"] }

    before do
      Rake.application.rake_require("tasks/correct_location_admin_district")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:scheme) { create(:scheme) }
      let!(:location) { create(:location, postcode: "A11AA", location_code: "E06000009", location_admin_district: nil, startdate: nil) }

      it "updates location with missing location admin district and marks it as complete" do
        expect(location.confirmed).to eq(false)
        task.invoke
        location.reload
        scheme.reload
        expect(location.confirmed).to eq(true)
        expect(location.location_admin_district).to eq("Blackpool")
      end

      it "does not mark location as complete if other fields are missing" do
        location.update!(units: nil)
        expect(location.confirmed).to eq(false)
        task.invoke
        location.reload
        scheme.reload
        expect(location.confirmed).to eq(false)
        expect(location.location_admin_district).to eq("Blackpool")
      end

      it "does not override existing location admin district" do
        location.location_admin_district = "Babergh"
        location.save!(validate: false)
        task.invoke
        expect(location.reload.location_admin_district).to eq("Babergh")
      end

      it "does not set location admin district if it cannot be found" do
        location.location_code = "123"
        location.save!(validate: false)
        task.invoke
        expect(location.reload.location_admin_district).to eq(nil)
      end
    end
  end
end
