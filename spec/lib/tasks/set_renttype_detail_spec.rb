require "rails_helper"
require "rake"

RSpec.describe "set_renttype_detail" do
  describe ":set_renttype_detail", type: :task do
    subject(:task) { Rake::Task["set_renttype_detail"] }

    before do
      Rake.application.rake_require("tasks/set_renttype_detail")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run and rent_type is 0" do
      let!(:lettings_log) { create(:lettings_log, :completed, rent_type: 0) }

      it "sets lettings log renttype_detail to 1" do
        expect(lettings_log.renttype_detail).to eq(nil)
        expected_updated_at = lettings_log.updated_at
        task.invoke
        lettings_log.reload
        expect(lettings_log.values_updated_at).to eq(nil)
        expect(lettings_log.updated_at).to eq(expected_updated_at)
        expect(lettings_log.renttype_detail).to eq(1)
      end
    end

    context "when the rake task is run and rent_type is 1" do
      let!(:lettings_log) { create(:lettings_log, :completed, rent_type: 1) }

      it "sets lettings log renttype_detail to 2" do
        expect(lettings_log.renttype_detail).to eq(nil)
        expected_updated_at = lettings_log.updated_at
        task.invoke
        lettings_log.reload
        expect(lettings_log.values_updated_at).to eq(nil)
        expect(lettings_log.updated_at).to eq(expected_updated_at)
        expect(lettings_log.renttype_detail).to eq(2)
      end
    end

    context "when the rake task is run and rent_type is 2" do
      let!(:lettings_log) { create(:lettings_log, :completed, rent_type: 2) }

      it "sets lettings log renttype_detail to 3" do
        expect(lettings_log.renttype_detail).to eq(nil)
        expected_updated_at = lettings_log.updated_at
        task.invoke
        lettings_log.reload
        expect(lettings_log.values_updated_at).to eq(nil)
        expect(lettings_log.updated_at).to eq(expected_updated_at)
        expect(lettings_log.renttype_detail).to eq(3)
      end
    end

    context "when the rake task is run and rent_type is 3" do
      let!(:lettings_log) { create(:lettings_log, :completed, rent_type: 3) }

      it "sets lettings log renttype_detail to 4" do
        expect(lettings_log.renttype_detail).to eq(nil)
        expected_updated_at = lettings_log.updated_at
        task.invoke
        lettings_log.reload
        expect(lettings_log.values_updated_at).to eq(nil)
        expect(lettings_log.updated_at).to eq(expected_updated_at)
        expect(lettings_log.renttype_detail).to eq(4)
      end
    end

    context "when the rake task is run and rent_type is 4" do
      let!(:lettings_log) { create(:lettings_log, :completed, rent_type: 4) }

      it "sets lettings log renttype_detail to 5" do
        expect(lettings_log.renttype_detail).to eq(nil)
        expected_updated_at = lettings_log.updated_at
        task.invoke
        lettings_log.reload
        expect(lettings_log.values_updated_at).to eq(nil)
        expect(lettings_log.updated_at).to eq(expected_updated_at)
        expect(lettings_log.renttype_detail).to eq(5)
      end
    end

    context "when the rake task is run and rent_type is 5" do
      let!(:lettings_log) { create(:lettings_log, :completed, rent_type: 5, irproduct_other: "sum") }

      it "sets lettings log renttype_detail to 6" do
        expect(lettings_log.renttype_detail).to eq(nil)
        expected_updated_at = lettings_log.updated_at
        task.invoke
        lettings_log.reload
        expect(lettings_log.values_updated_at).to eq(nil)
        expect(lettings_log.updated_at).to eq(expected_updated_at)
        expect(lettings_log.renttype_detail).to eq(6)
      end
    end
  end
end
