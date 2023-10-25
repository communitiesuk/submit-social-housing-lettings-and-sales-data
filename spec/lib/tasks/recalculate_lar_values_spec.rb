require "rails_helper"
require "rake"

RSpec.describe "recalculate_lar_values" do
  describe ":recalculate_lar_values", type: :task do
    subject(:task) { Rake::Task["recalculate_lar_values"] }

    before do
      Rake.application.rake_require("tasks/recalculate_lar_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:lettings_log) { create(:lettings_log, :completed, values_updated_at: nil) }

      it "updates lar to nil if it's not afordable rent or london afordable rent and lar is 1 but does not set it to export" do
        lettings_log.lar = 1
        lettings_log.rent_type = 3
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.lar).to eq(nil)
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "updates lar to nil if it's not afordable rent or london afordable rent and lar is 2 but does not set it to export" do
        lettings_log.lar = 2
        lettings_log.rent_type = 4
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.lar).to eq(nil)
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "does not update lar if it's not london afordable rent or affordable rent and lar is nil" do
        lettings_log.lar = nil
        lettings_log.rent_type = 3
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.lar).to eq(nil)
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "updates lar to 1 if it's london afordable rent and lar is currently nil" do
        lettings_log.lar = nil
        lettings_log.rent_type = 2
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.lar).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates lar to 1 if it's london afordable rent and lar is currently 2" do
        lettings_log.lar = 2
        lettings_log.rent_type = 2
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.lar).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates lar to 2 if it's afordable rent and lar is currently nil" do
        lettings_log.lar = nil
        lettings_log.rent_type = 1
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.lar).to eq(2)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates lar to 2 if it's afordable rent and lar is currently 1" do
        lettings_log.lar = 1
        lettings_log.rent_type = 1
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.lar).to eq(2)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "does not update lar if a different validation is triggering" do
        lettings_log.lar = 1
        lettings_log.rent_type = 1
        lettings_log.postcode_full = "invalid"
        lettings_log.save!(validate: false)
        expect(Rails.logger).to receive(:info).with("Could not update lar for LettingsLog #{lettings_log.id}")
        task.invoke
        lettings_log.reload
        expect(lettings_log.lar).to eq(1)
        expect(lettings_log.values_updated_at).to be_nil
      end
    end
  end
end
