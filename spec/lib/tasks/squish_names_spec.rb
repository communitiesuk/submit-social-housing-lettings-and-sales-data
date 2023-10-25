require "rails_helper"
require "rake"

RSpec.describe "squish_names" do
  describe ":squish_names", type: :task do
    subject(:task) { Rake::Task["squish_names"] }

    before do
      Rake.application.rake_require("tasks/squish_names")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:scheme) { create(:scheme) }
      let!(:location) { create(:location) }
      let!(:user) { create(:user) }
      let!(:organisation) { create(:organisation) }

      it "updates names with multiple spaces to only have one" do
        scheme.service_name = "test  test"
        location.name = "test test  test"
        user.name = "test        test"
        organisation.name = "test  test  test"

        scheme.save!(validate: false)
        location.save!(validate: false)
        user.save!(validate: false)
        organisation.save!(validate: false)

        task.invoke
        scheme.reload
        location.reload
        user.reload
        organisation.reload
        expect(scheme.service_name).to eq("test test")
        expect(location.name).to eq("test test test")
        expect(user.name).to eq("test test")
        expect(organisation.name).to eq("test test test")
      end

      it "does not update names without multiple spaces" do
        scheme.service_name = "test test"
        location.name = "test test test"
        user.name = "test test"
        organisation.name = "test test test"

        scheme.save!(validate: false)
        location.save!(validate: false)
        user.save!(validate: false)
        organisation.save!(validate: false)

        task.invoke
        scheme.reload
        location.reload
        user.reload
        organisation.reload
        expect(scheme.service_name).to eq("test test")
        expect(location.name).to eq("test test test")
        expect(user.name).to eq("test test")
        expect(organisation.name).to eq("test test test")
      end
    end
  end
end
