require "rails_helper"

RSpec.describe Validations::Sales::SoftValidations do
  let(:record) { FactoryBot.create(:sales_log) }

  describe "income1 min validations" do
    context "when validating soft min" do
      it "returns false if no income1 is given" do
        record.income1 = nil
        expect(record)
          .not_to be_income1_under_soft_min
      end

      it "returns false if no ecstat1 is given" do
        record.ecstat1 = nil
        expect(record)
          .not_to be_income1_under_soft_min
      end

      [
        {
          income1: 4500,
          ecstat1: 1,
        },
        {
          income1: 1400,
          ecstat1: 2,
        },
        {
          income1: 999,
          ecstat1: 3,
        },
        {
          income1: 1899,
          ecstat1: 5,
        },
        {
          income1: 1888,
          ecstat1: 0,
        },
      ].each do |test_case|
        it "returns true if income1 is below soft min for ecstat1 #{test_case[:ecstat1]}" do
          record.income1 = test_case[:income1]
          record.ecstat1 = test_case[:ecstat1]
          expect(record)
            .to be_income1_under_soft_min
        end
      end

      [
        {
          income1: 5001,
          ecstat1: 1,
        },
        {
          income1: 1600,
          ecstat1: 2,
        },
        {
          income1: 1004,
          ecstat1: 3,
        },
        {
          income1: 2899,
          ecstat1: 4,
        },
        {
          income1: 2899,
          ecstat1: 5,
        },
        {
          income1: 5,
          ecstat1: 6,
        },
        {
          income1: 10_888,
          ecstat1: 0,
        },
      ].each do |test_case|
        it "returns false if income1 is over soft min for ecstat1 #{test_case[:ecstat1]}" do
          record.income1 = test_case[:income1]
          record.ecstat1 = test_case[:ecstat1]
          expect(record)
            .not_to be_income1_under_soft_min
        end
      end
    end
  end
end
