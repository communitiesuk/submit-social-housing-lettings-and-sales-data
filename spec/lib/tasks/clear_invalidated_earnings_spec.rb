require "rails_helper"
require "rake"

RSpec.describe "clear_invalidated_earnings" do
  describe ":clear_invalidated_earnings", type: :task do
    subject(:task) { Rake::Task["clear_invalidated_earnings"] }

    before do
      Rake.application.rake_require("tasks/clear_invalidated_earnings")
      Rake::Task.define_task(:environment)
      task.reenable
      FormHandler.instance.use_real_forms!
    end

    context "when the rake task is run" do
      context "and there are 2023 logs with invalid earnings" do
        let(:user) { create(:user) }
        let!(:lettings_log) { create(:lettings_log, :completed, assigned_to: user, voiddate: nil, mrcdate: nil, tenancycode: "123", propcode: "321") }

        before do
          lettings_log.startdate = Time.zone.local(2023, 4, 4)
          lettings_log.incfreq = 1
          lettings_log.earnings = 20
          lettings_log.hhmemb = 1
          lettings_log.ecstat1 = 1
          lettings_log.save!(validate: false)
        end

        it "clears earnings" do
          initial_updated_at = lettings_log.updated_at
          expect(lettings_log.incfreq).to eq(1)
          expect(lettings_log.earnings).to eq(20)
          expect(lettings_log.hhmemb).to eq(1)
          expect(lettings_log.ecstat1).to eq(1)
          expect(Rails.logger).to receive(:info).with("Clearing earnings for lettings log #{lettings_log.id}, owning_organisation_id: #{lettings_log.owning_organisation_id}, managing_organisation_id: #{lettings_log.managing_organisation_id}, startdate: 2023-04-04, tenancy reference: 123, property reference: 321, assigned_to: #{user.email}(#{user.id}), earnings: 20, incfreq: 1")

          task.invoke
          lettings_log.reload

          expect(lettings_log.incfreq).to eq(nil)
          expect(lettings_log.earnings).to eq(nil)
          expect(lettings_log.hhmemb).to eq(1)
          expect(lettings_log.ecstat1).to eq(1)
          expect(lettings_log.updated_at).not_to eq(initial_updated_at)
        end
      end

      context "and there are valid 2023 logs" do
        let(:user) { create(:user) }
        let!(:lettings_log) { create(:lettings_log, :completed, assigned_to: user, voiddate: nil, mrcdate: nil) }

        before do
          lettings_log.startdate = Time.zone.local(2023, 4, 4)
          lettings_log.incfreq = 1
          lettings_log.earnings = 95
          lettings_log.hhmemb = 1
          lettings_log.ecstat1 = 1
          lettings_log.save!(validate: false)
        end

        it "does not update the logs" do
          initial_updated_at = lettings_log.updated_at
          expect(lettings_log.incfreq).to eq(1)
          expect(lettings_log.earnings).to eq(95)
          expect(lettings_log.hhmemb).to eq(1)
          expect(lettings_log.ecstat1).to eq(1)

          task.invoke
          lettings_log.reload

          expect(lettings_log.incfreq).to eq(1)
          expect(lettings_log.earnings).to eq(95)
          expect(lettings_log.hhmemb).to eq(1)
          expect(lettings_log.ecstat1).to eq(1)
          expect(lettings_log.updated_at).to eq(initial_updated_at)
        end
      end

      context "and there are 2022 logs" do
        let(:user) { create(:user) }
        let!(:lettings_log) { create(:lettings_log, :completed, assigned_to: user, voiddate: nil, mrcdate: nil) }

        before do
          lettings_log.startdate = Time.zone.local(2022, 4, 4)
          lettings_log.incfreq = 1
          lettings_log.earnings = 20
          lettings_log.hhmemb = 1
          lettings_log.ecstat1 = 1
          lettings_log.save!(validate: false)
        end

        it "does not update the logs" do
          initial_updated_at = lettings_log.updated_at
          expect(lettings_log.incfreq).to eq(1)
          expect(lettings_log.earnings).to eq(20)
          expect(lettings_log.hhmemb).to eq(1)
          expect(lettings_log.ecstat1).to eq(1)

          task.invoke
          lettings_log.reload

          expect(lettings_log.incfreq).to eq(1)
          expect(lettings_log.earnings).to eq(20)
          expect(lettings_log.hhmemb).to eq(1)
          expect(lettings_log.ecstat1).to eq(1)
          expect(lettings_log.updated_at).to eq(initial_updated_at)
        end
      end
    end
  end
end
