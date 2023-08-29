require "rails_helper"
require "rake"

RSpec.describe "correct_has_other_client_group_values" do
  describe ":correct_has_other_client_group_values", type: :task do
    subject(:task) { Rake::Task["correct_has_other_client_group_values"] }

    before do
      Rake.application.rake_require("tasks/correct_has_other_client_group_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:scheme) { create(:scheme, secondary_client_group: nil) }

      before do
        scheme.has_other_client_group = nil
        scheme.save!(validate: false)
      end

      context "and the scheme is marked confirmed" do
        it "updates schemes with secondary_client_group to have has_other_client_group 1 (yes)" do
          scheme.secondary_client_group = "G"
          scheme.save!(validate: false)
          task.invoke
          expect(scheme.reload.has_other_client_group).to eq("Yes")
        end

        it "updates schemes without secondary_client_group to have has_other_client_group 0 (no)" do
          task.invoke
          expect(scheme.reload.has_other_client_group).to eq("No")
        end
      end

      context "and the scheme is not marked confirmed" do
        before do
          scheme.confirmed = false
          scheme.save!(validate: false)
        end

        it "does not update schemes with secondary_client_group" do
          scheme.secondary_client_group = "G"
          scheme.save!(validate: false)
          task.invoke
          expect(scheme.reload.has_other_client_group).to eq(nil)
        end

        it "does not update schemes without secondary_client_group" do
          task.invoke
          expect(scheme.reload.has_other_client_group).to eq(nil)
        end
      end
    end
  end
end
