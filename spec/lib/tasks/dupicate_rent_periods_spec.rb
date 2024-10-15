require "rails_helper"
require "rake"

RSpec.describe "duplicate_rent_periods" do
  before do
    Rake.application.rake_require("tasks/duplicate_rent_periods")
    Rake::Task.define_task(:environment)
    allow(Rails.logger).to receive(:info)
    organisation = create(:organisation, rent_periods: (2..11).to_a)

    [2, 4, 6, 11, 2, 11, 11].each do |rent_period|
      org_rent_period = build(:organisation_rent_period, organisation:, rent_period:)
      org_rent_period.save!(validate: false)
    end
  end

  describe "find_duplicate_rent_periods" do
    let(:task) { Rake::Task["find_duplicate_rent_periods"] }

    before do
      task.reenable
    end

    it "logs the correct information about duplicate rent periods" do
      task.invoke

      expect(Rails.logger).to have_received(:info).with(include("Total number of records: 17"))
      expect(Rails.logger).to have_received(:info).with(include("Number of affected records: 11"))
      expect(Rails.logger).to have_received(:info).with(include("Number of affected records to delete: 7"))
      expect(Rails.logger).to have_received(:info).with(include("Number of affected records to keep: 4"))
    end
  end

  describe "delete_duplicate_rent_periods" do
    let(:task) { Rake::Task["delete_duplicate_rent_periods"] }

    before do
      task.reenable
    end

    it "deletes redundant rent periods" do
      expect { task.invoke }.to change(OrganisationRentPeriod, :count).by(-7)
      expect(Rails.logger).to have_received(:info).with(include("Number of deleted duplicate records: 7"))

      remaining_rent_periods = OrganisationRentPeriod.pluck(:rent_period)
      expect(remaining_rent_periods).to match_array((2..11).to_a)
    end
  end
end
