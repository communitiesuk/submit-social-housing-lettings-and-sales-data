require "rails_helper"
require "rake"

RSpec.describe "recalculate_refused_values" do
  describe ":recalculate_refused_values", type: :task do
    subject(:task) { Rake::Task["recalculate_refused_values"] }

    before do
      Rake.application.rake_require("tasks/recalculate_refused_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:lettings_log) { create(:lettings_log, :completed, values_updated_at: nil) }

      it "updates refused value to 1 if details for person are not known" do
        lettings_log.refused = 0
        lettings_log.details_known_2 = 1
        lettings_log.hhmemb = 2
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.refused).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "does not update refused value if details known is nil" do
        lettings_log.update!(details_known_2: nil, hhmemb: 2)
        lettings_log.refused = 0
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.refused).to eq(0)
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "does not update refused value if details are known" do
        lettings_log.refused = 0
        lettings_log.details_known_2 = 0
        lettings_log.hhmemb = 2
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.refused).to eq(0)
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "updates refused value to 1 if details for any person are not known" do
        lettings_log.refused = 0
        lettings_log.details_known_2 = 0
        lettings_log.details_known_3 = 0
        lettings_log.details_known_4 = 0
        lettings_log.details_known_5 = 0
        lettings_log.details_known_6 = 1
        lettings_log.details_known_7 = 0
        lettings_log.details_known_8 = 0
        lettings_log.hhmemb = 8
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.refused).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "updates values updated at if refused is already set to 1 but some details are unknown" do
        lettings_log.refused = 1
        lettings_log.details_known_2 = 0
        lettings_log.details_known_3 = 0
        lettings_log.details_known_4 = 0
        lettings_log.details_known_5 = 0
        lettings_log.details_known_6 = 1
        lettings_log.details_known_7 = 0
        lettings_log.details_known_8 = 0
        lettings_log.hhmemb = 8
        lettings_log.save!(validate: false)
        task.invoke
        lettings_log.reload
        expect(lettings_log.refused).to eq(1)
        expect(lettings_log.values_updated_at).not_to be_nil
      end
    end
  end
end
