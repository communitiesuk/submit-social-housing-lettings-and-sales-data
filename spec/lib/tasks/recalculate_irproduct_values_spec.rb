require "rails_helper"
require "rake"

RSpec.describe "recalculate_irproduct_values" do
  describe ":recalculate_irproduct_values", type: :task do
    subject(:task) { Rake::Task["recalculate_irproduct_values"] }

    before do
      Rake.application.rake_require("tasks/recalculate_irproduct_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:lettings_log) { create(:lettings_log, :completed, values_updated_at: nil) }

      it "updates irproduct to nil if it's set to 1 but rent type is not 3, 4 or 5" do
        lettings_log.irproduct = 1
        lettings_log.rent_type = 2
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(nil)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates irproduct to nil if it's set to 2 but rent type is not 3, 4 or 5" do
        lettings_log.irproduct = 2
        lettings_log.rent_type = 2
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(nil)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates irproduct to nil if it's set to 3 but rent type is not 3, 4 or 5" do
        lettings_log.irproduct = 3
        lettings_log.rent_type = 2
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(nil)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates irproduct to 1 if it's set to nil but rent type is 3" do
        lettings_log.irproduct = nil
        lettings_log.rent_type = 3
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates irproduct to 1 if it's set to something else but rent type is 3" do
        lettings_log.irproduct = 2
        lettings_log.rent_type = 3
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates irproduct to 2 if it's set to nil but rent type is 4" do
        lettings_log.irproduct = nil
        lettings_log.rent_type = 4
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(2)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates irproduct to 2 if it's set to something else but rent type is 4" do
        lettings_log.irproduct = 1
        lettings_log.rent_type = 4
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(2)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates irproduct to 3 if it's set to nil but rent type is 5" do
        lettings_log.irproduct = nil
        lettings_log.rent_type = 5
        lettings_log.irproduct_other = "other"
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(3)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates irproduct to 3 if it's set to something else but rent type is 5" do
        lettings_log.irproduct = 2
        lettings_log.rent_type = 5
        lettings_log.irproduct_other = "other"
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(3)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "does not update irproduct if rent_type is not 3, 4 or 5 and irproduct is nil" do
        lettings_log.irproduct = nil
        lettings_log.rent_type = 2
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(nil)
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "does not update irproduct if a different validation is triggering" do
        lettings_log.irproduct = 2
        lettings_log.rent_type = 5
        lettings_log.postcode_full = "invalid"
        lettings_log.save!(validate: false)
        expect(Rails.logger).to receive(:info).with("Could not update irproduct for LettingsLog #{lettings_log.id}")
        task.invoke
        lettings_log.reload
        expect(lettings_log.irproduct).to eq(2)
        expect(lettings_log.values_updated_at).to be_nil
      end
    end
  end
end
