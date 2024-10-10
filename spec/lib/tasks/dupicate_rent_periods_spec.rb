require "rails_helper"
require "rake"

RSpec.describe "duplicate_rent_periods" do
  before(:all) do
    Rake.application.rake_require("tasks/duplicate_rent_periods")
    Rake::Task.define_task(:environment)
  end

  describe "find_redundant_rent_periods" do
    let(:task) { Rake::Task["find_redundant_rent_periods"] }

    before do
      task.reenable
    end

    it "logs the correct information about duplicate rent periods" do
      allow(Rails.logger).to receive(:info)
      organisation = create(:organisation, rent_periods: (1..11).to_a)

      [2,4,6,11].each do |rent_period|
        org_rent_period = build(:organisation_rent_period, organisation: organisation)
        org_rent_period.save(validate: false)
        org_rent_period.update_column(:rent_period, rent_period)
      end

      task.invoke

      expect(Rails.logger).to have_received(:info).with(include("Total number of records: 15"))
      expect(Rails.logger).to have_received(:info).with(include("Number of affected records: 8"))
      expect(Rails.logger).to have_received(:info).with(include("Number of records to delete: 4"))
      expect(Rails.logger).to have_received(:info).with(include("Number of records to keep: 4"))
    end
  end

  describe "delete_duplicate_rent_periods" do
    let(:task) { Rake::Task["delete_duplicate_rent_periods"] }

    before do
      task.reenable
    end

    it "deletes redundant rent periods" do
      allow(Rails.logger).to receive(:info)
      organisation = create(:organisation, rent_periods: (1..11).to_a)

      [2,4,6,11].each do |rent_period|
        org_rent_period = build(:organisation_rent_period, organisation: organisation)
        org_rent_period.save(validate: false)
        org_rent_period.update_column(:rent_period, rent_period)
      end

      expect { task.invoke }.to change { OrganisationRentPeriod.count }.by(-4)
      expect(Rails.logger).to have_received(:info).with(include("Number of deleted duplicate records: 4"))
    end
  end
end
