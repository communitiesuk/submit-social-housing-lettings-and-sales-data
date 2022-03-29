require "rails_helper"

RSpec.describe Validations::SoftValidations do
  let(:record) { FactoryBot.create(:case_log) }

  describe "rent min max validations" do
    before do
      LaRentRange.create!(
        ranges_rent_id: "1",
        la: "E07000223",
        beds: 1,
        lettype: 1,
        soft_min: 12.41,
        soft_max: 89.54,
        hard_min: 9.87,
        hard_max: 100.99,
        start_year: 2021,
      )

      record.la = "E07000223"
      record.lettype = 1
      record.beds = 1
      record.period = 1
      record.startdate = Time.zone.local(2021, 10, 10)
    end

    context "when validating soft min" do
      before do
        record.brent = 11
      end

      it "returns out of soft min range if no startdate is given" do
        record.startdate = nil
        expect(record)
          .not_to be_rent_in_soft_min_range
      end

      it "returns out of soft min range if no brent is given" do
        record.brent = nil
        expect(record)
          .not_to be_rent_in_soft_min_range
      end

      it "returns true if weekly rent is in soft min range" do
        expect(record)
          .to be_rent_in_soft_min_range
      end
    end

    context "when validating soft max" do
      before do
        record.brent = 90
      end

      it "returns out of soft max range if no startdate is given" do
        record.startdate = nil
        expect(record)
          .not_to be_rent_in_soft_max_range
      end

      it "returns out of soft max range if no brent is given" do
        record.brent = nil
        expect(record)
          .not_to be_rent_in_soft_max_range
      end

      it "returns true if weekly rent is in soft max range" do
        expect(record)
          .to be_rent_in_soft_max_range
      end
    end
  end
end
