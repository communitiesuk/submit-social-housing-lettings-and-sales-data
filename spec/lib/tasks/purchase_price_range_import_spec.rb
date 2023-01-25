require "rails_helper"
require "rake"

RSpec.describe "data_import" do
  describe ":purchase_price_ranges", type: :task do
    subject(:task) { Rake::Task["data_import:purchase_price_ranges"] }

    before do
      Rake.application.rake_require("tasks/purchase_price_ranges")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:start_year) { 2022 }
      let(:purchase_price_ranges_file_path) { "./spec/fixtures/files/purchase_price_ranges.csv" }
      let(:wrong_file_path) { "/test/no_csv_here.csv" }

      it "creates new rent range records" do
        expect { task.invoke(start_year, purchase_price_ranges_file_path) }.to change(LaPurchasePriceRange, :count).by(4)
        expect(LaPurchasePriceRange.where(bedrooms: 1).exists?).to be true
      end

      it "raises an error when no path is given" do
        expect { task.invoke(start_year, nil) }.to raise_error(RuntimeError, "Usage: rake data_import:purchase_price_ranges[start_year,'path/to/csv_file']")
      end

      it "raises an error when no file exists at the given path" do
        expect { task.invoke(start_year, wrong_file_path) }.to raise_error(Errno::ENOENT)
      end

      it "asks for a start year if it is not given" do
        expect { task.invoke(nil, purchase_price_ranges_file_path) }.to raise_error(RuntimeError, "Usage: rake data_import:purchase_price_ranges[start_year,'path/to/csv_file']")
      end

      context "when a record already exists with a matching index of la, bedrooms and start year" do
        let!(:purchase_price_range) { LaPurchasePriceRange.create(la: "E07000223", bedrooms: 2, soft_min: 177_000, soft_max: 384_000, start_year: 2022) }

        it "updates rent ranges if the record is matched on la, bedrooms and start year" do
          task.invoke(start_year, purchase_price_ranges_file_path)
          purchase_price_range.reload
          expect(purchase_price_range.soft_max).to eq(384_000)
        end
      end
    end
  end
end
