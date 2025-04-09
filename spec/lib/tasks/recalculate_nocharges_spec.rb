require "rails_helper"
require "rake"

RSpec.describe "recalculate_nocharges", type: :task do
  before do
    Rake.application.rake_require("tasks/recalculate_nocharges")
    Rake::Task.define_task(:environment)
    task.reenable
  end

  describe "bulk_update:update_current_logs_nocharges" do
    let(:task) { Rake::Task["bulk_update:update_current_logs_nocharges"] }
    let(:organisation) { FactoryBot.create(:organisation, name: "MHCLG", provider_type: "LA", housing_registration_no: 1234) }
    let(:user) { FactoryBot.create(:user, organisation:, email: "fake@email.com") }
    let(:scheme) { FactoryBot.create(:scheme, :export, owning_organisation: organisation) }
    let(:location) { FactoryBot.create(:location, :export, scheme:, startdate: Time.zone.local(2021, 4, 1), old_id: "1a") }

    let(:log_to_update) do
      build(:lettings_log, :completed, :sh, needstype: 2, scheme:, location:, assigned_to: user, startdate: Time.zone.local(2024, 6, 1), age1: 35, sex1: "F", age2: 32, sex2: "M", underoccupation_benefitcap: 4, sheltered: 1, household_charge: 0, nocharge: 1)
    end

    let(:log_not_to_update) do
      build(:lettings_log, :completed, needstype: 2, household_charge: 1, nocharge: 1)
    end

    context "when running the task" do
      before do
        log_to_update.save!(validate: false)
        log_not_to_update.save!(validate: false)
      end

      it "updates logs where household_charge and nocharge are different" do
        expect(log_to_update.nocharge).to eq(1)
        expect(log_to_update.household_charge).to eq(0)

        task.invoke

        log_to_update.reload
        expect(log_to_update.nocharge).to eq(0)
      end

      it "does not update logs where household_charge and nocharge are the same" do
        expect(log_not_to_update.nocharge).to eq(1)
        expect(log_not_to_update.household_charge).to eq(1)

        task.invoke

        log_not_to_update.reload
        expect(log_not_to_update.nocharge).to eq(1)
      end
    end
  end
end
