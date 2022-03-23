require "rails_helper"
require "rake"

RSpec.describe "data_import" do
  describe ":rent_ranges", type: :task do
    subject(:task) { Rake::Task["data_import:rent_ranges"] }

    before do
      Rake.application.rake_require("tasks/rent_ranges")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:start_year) { 2021 }
      let(:rent_ranges_file_path) { "./spec/fixtures/files/rent_ranges.csv" }
      let(:wrong_file_path) { "/test/no_csv_here.csv" }

      it "creates new rent range records" do
        expect { task.invoke(start_year, rent_ranges_file_path) }.to change(LaRentRange, :count).by(5)
        expect(LaRentRange.where(ranges_rent_id: 1).exists?).to be true
      end

      it "raises an error when no path is given" do
        expect { task.invoke(start_year, nil) }.to raise_error(RuntimeError, "Usage: rake data_import:rent_ranges[start_year,'path/to/csv_file']")
      end

      it "raises an error when no file exists at the given path" do
        expect { task.invoke(start_year, wrong_file_path) }.to raise_error(Errno::ENOENT)
      end

      it "asks for a start year if it is not given" do
        expect { task.invoke(nil, rent_ranges_file_path) }.to raise_error(RuntimeError, "Usage: rake data_import:rent_ranges[start_year,'path/to/csv_file']")
      end

      context "when a record already exists with a matching index of la, beds, start year and lettype" do
        let!(:rent_range) { LaRentRange.create(lettype: 1, la: "E07000223", beds: 2, soft_min: 53.5, soft_max: 149.4, hard_min: 20.36, hard_max: 200.57, start_year: 2021) }

        it "updates rent ranges if the record is matched on la, beds, start year and lettype" do
          task.invoke(start_year, rent_ranges_file_path)
          rent_range.reload
          expect(rent_range.hard_max).to eq(190.57)
        end
      end
    end
  end
end
