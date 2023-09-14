require "rails_helper"
require "rake"

RSpec.describe "confirm_charges_soft_validations" do
  describe ":confirm_charges_soft_validations", type: :task do
    subject(:task) { Rake::Task["confirm_charges_soft_validations"] }

    before do
      Rake.application.rake_require("tasks/confirm_charges_soft_validations")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let!(:lettings_log) { create(:lettings_log, :completed) }

      it "confirms scharge value check for lettings logs with scharge over soft max" do
        lettings_log.scharge = 404
        lettings_log.skip_update_status = true
        lettings_log.save!(validate: false)
        lettings_log.skip_update_status = nil
        task.invoke
        expect(lettings_log.reload.scharge_value_check).to eq(0)
        expect(lettings_log.status).to eq("completed")
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "does not confirm scharge value check for lettings logs with scharge under soft max" do
        lettings_log.scharge = 40
        lettings_log.skip_update_status = true
        lettings_log.save!(validate: false)
        lettings_log.skip_update_status = nil
        task.invoke
        expect(lettings_log.reload.scharge_value_check).to eq(nil)
        expect(lettings_log.status).to eq("completed")
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "does not confirm scharge value check for in progress logs" do
        lettings_log.update!(scharge: 404, reason: nil, status: "in_progress")
        expect(lettings_log.reload.status).to eq("in_progress")
        task.invoke
        expect(lettings_log.reload.scharge_value_check).to eq(nil)
        expect(lettings_log.status).to eq("in_progress")
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "does not confirm scharge value check if it already is confirmed" do
        lettings_log.update!(scharge: 404, scharge_value_check: 0)
        expect(lettings_log.reload.status).to eq("completed")
        task.invoke
        expect { task.invoke }.not_to change(lettings_log.reload, :scharge_value_check)
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "confirms pscharge value check for lettings logs with pscharge over soft max" do
        lettings_log.pscharge = 204
        lettings_log.skip_update_status = true
        lettings_log.save!(validate: false)
        lettings_log.skip_update_status = nil
        task.invoke
        expect(lettings_log.reload.pscharge_value_check).to eq(0)
        expect(lettings_log.status).to eq("completed")
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "does not confirm pscharge value check for lettings logs with pscharge under soft max" do
        lettings_log.pscharge = 40
        lettings_log.skip_update_status = true
        lettings_log.save!(validate: false)
        lettings_log.skip_update_status = nil
        task.invoke
        expect(lettings_log.reload.pscharge_value_check).to eq(nil)
        expect(lettings_log.status).to eq("completed")
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "does not confirm pscharge value check for in progress logs" do
        lettings_log.update!(pscharge: 204, reason: nil, status: "in_progress")
        expect(lettings_log.reload.status).to eq("in_progress")
        task.invoke
        expect(lettings_log.reload.pscharge_value_check).to eq(nil)
        expect(lettings_log.status).to eq("in_progress")
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "does not confirm pscharge value check if it already is confirmed" do
        lettings_log.update!(pscharge: 204, pscharge_value_check: 0)
        expect(lettings_log.reload.status).to eq("completed")
        task.invoke
        expect { task.invoke }.not_to change(lettings_log.reload, :pscharge_value_check)
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "confirms supcharg value check for lettings logs with supcharg over soft max" do
        lettings_log.supcharg = 204
        lettings_log.skip_update_status = true
        lettings_log.save!(validate: false)
        lettings_log.skip_update_status = nil
        task.invoke
        expect(lettings_log.reload.supcharg_value_check).to eq(0)
        expect(lettings_log.status).to eq("completed")
        expect(lettings_log.values_updated_at).not_to be_nil
      end

      it "does not confirm supcharg value check for lettings logs with supcharg under soft max" do
        lettings_log.supcharg = 40
        lettings_log.skip_update_status = true
        lettings_log.save!(validate: false)
        lettings_log.skip_update_status = nil
        task.invoke
        expect(lettings_log.reload.supcharg_value_check).to eq(nil)
        expect(lettings_log.status).to eq("completed")
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "does not confirm supcharg value check for in progress logs" do
        lettings_log.update!(supcharg: 204, reason: nil, status: "in_progress")
        expect(lettings_log.reload.status).to eq("in_progress")
        task.invoke
        expect(lettings_log.reload.supcharg_value_check).to eq(nil)
        expect(lettings_log.status).to eq("in_progress")
        expect(lettings_log.values_updated_at).to be_nil
      end

      it "does not confirm supcharg value check if it already is confirmed" do
        lettings_log.update!(supcharg: 204, supcharg_value_check: 0)
        expect(lettings_log.reload.status).to eq("completed")
        task.invoke
        expect { task.invoke }.not_to change(lettings_log.reload, :supcharg_value_check)
        expect(lettings_log.values_updated_at).to be_nil
      end
    end
  end
end
