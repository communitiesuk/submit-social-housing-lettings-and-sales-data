require "rails_helper"
require "rake"

RSpec.describe "update_created_by_values" do
  describe ":update_created_by_values", type: :task do
    subject(:task) { Rake::Task["update_created_by_values"] }

    before do
      Rake.application.rake_require("tasks/update_created_by_values")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      let(:user) { create(:user) }

      context "with bulk upload id" do
        let(:bulk_upload) { create(:bulk_upload) }
        let(:lettings_log) { create(:lettings_log, :completed, assigned_to: user, bulk_upload_id: bulk_upload.id, updated_at: Time.zone.yesterday, startdate: Time.zone.local(2024, 9, 9)) }
        let(:sales_log) { create(:sales_log, :completed, assigned_to: user, bulk_upload_id: bulk_upload.id, updated_at: Time.zone.yesterday, saledate: Time.zone.local(2024, 9, 9)) }

        it "updates created_by to bulk upload user id for lettings log" do
          initial_updated_at = lettings_log.updated_at
          expect(lettings_log.created_by_id).to eq(user.id)
          expect(lettings_log.assigned_to_id).to eq(user.id)
          task.invoke
          lettings_log.reload
          expect(lettings_log.created_by_id).to eq(bulk_upload.user_id)
          expect(lettings_log.assigned_to_id).to eq(user.id)
          expect(lettings_log.updated_at).to eq(initial_updated_at)
        end

        it "updates created_by to bulk upload user id for sales log" do
          initial_updated_at = sales_log.updated_at
          expect(sales_log.created_by_id).to eq(user.id)
          expect(sales_log.assigned_to_id).to eq(user.id)
          task.invoke
          sales_log.reload
          expect(sales_log.created_by_id).to eq(bulk_upload.user_id)
          expect(sales_log.assigned_to_id).to eq(user.id)
          expect(sales_log.updated_at).to eq(initial_updated_at)
        end
      end

      context "without bulk upload id" do
        context "and version whodunnit exists for create" do
          let(:lettings_log) { create(:lettings_log, :completed, assigned_to: user, created_by_id: nil, updated_at: Time.zone.yesterday, startdate: Time.zone.local(2024, 9, 9)) }
          let(:sales_log) { create(:sales_log, :completed, assigned_to: user, created_by_id: nil, updated_at: Time.zone.yesterday, saledate: Time.zone.local(2024, 9, 9)) }
          let(:other_user) { create(:user, organisation: user.organisation) }

          before do
            PaperTrail::Version.find_by(item_id: lettings_log.id, item_type: "LettingsLog", event: "create").update!(whodunnit: other_user.to_global_id.uri.to_s)
            PaperTrail::Version.find_by(item_id: sales_log.id, item_type: "SalesLog", event: "create").update!(whodunnit: other_user.to_global_id.uri.to_s)
          end

          it "updates created_by to create whodunnit for lettings" do
            initial_updated_at = lettings_log.updated_at
            expect(lettings_log.created_by_id).to eq(nil)
            expect(lettings_log.assigned_to_id).to eq(user.id)
            task.invoke
            lettings_log.reload
            expect(lettings_log.created_by_id).to eq(other_user.id)
            expect(lettings_log.assigned_to_id).to eq(user.id)
            expect(lettings_log.updated_at).to eq(initial_updated_at)
          end

          it "updates created_by to create whodunnit for sales" do
            initial_updated_at = sales_log.updated_at
            expect(sales_log.created_by_id).to eq(nil)
            expect(sales_log.assigned_to_id).to eq(user.id)
            task.invoke
            sales_log.reload
            expect(sales_log.created_by_id).to eq(other_user.id)
            expect(sales_log.assigned_to_id).to eq(user.id)
            expect(sales_log.updated_at).to eq(initial_updated_at)
          end
        end

        context "and version whodunnit does not exist for create" do
          let(:lettings_log) { create(:lettings_log, :completed, assigned_to: user, created_by_id: nil, updated_at: Time.zone.yesterday, startdate: Time.zone.local(2024, 9, 9)) }
          let(:sales_log) { create(:sales_log, :completed, assigned_to: user, created_by_id: nil, updated_at: Time.zone.yesterday, saledate: Time.zone.local(2024, 9, 9)) }

          before do
            PaperTrail::Version.find_by(item_id: lettings_log.id, event: "create").update!(whodunnit: nil)
            PaperTrail::Version.find_by(item_id: sales_log.id, event: "create").update!(whodunnit: nil)
          end

          it "sets created_by to assigned_to for lettings" do
            initial_updated_at = lettings_log.updated_at
            expect(lettings_log.created_by_id).to eq(nil)
            expect(lettings_log.assigned_to_id).to eq(user.id)
            task.invoke
            lettings_log.reload
            expect(lettings_log.created_by_id).to eq(user.id)
            expect(lettings_log.assigned_to_id).to eq(user.id)
            expect(lettings_log.updated_at).to eq(initial_updated_at)
          end

          it "sets created_by to assigned_to for sales" do
            initial_updated_at = sales_log.updated_at
            expect(sales_log.created_by_id).to eq(nil)
            expect(sales_log.assigned_to_id).to eq(user.id)
            task.invoke
            sales_log.reload
            expect(sales_log.created_by_id).to eq(user.id)
            expect(sales_log.assigned_to_id).to eq(user.id)
            expect(sales_log.updated_at).to eq(initial_updated_at)
          end
        end

        context "and version whodunnit is not a User for create" do
          let(:lettings_log) { create(:lettings_log, :completed, assigned_to: user, created_by_id: nil, updated_at: Time.zone.yesterday, startdate: Time.zone.local(2024, 9, 9)) }
          let(:sales_log) { create(:sales_log, :completed, assigned_to: user, created_by_id: nil, updated_at: Time.zone.yesterday, saledate: Time.zone.local(2024, 9, 9)) }
          let(:other_user) { create(:user, organisation: user.organisation) }

          before do
            PaperTrail::Version.find_by(item_id: lettings_log.id, item_type: "LettingsLog", event: "create").update!(whodunnit: other_user.email)
            PaperTrail::Version.find_by(item_id: sales_log.id, item_type: "SalesLog", event: "create").update!(whodunnit: other_user.email)
          end

          it "sets created_by to assigned_to for lettings" do
            initial_updated_at = lettings_log.updated_at
            expect(lettings_log.created_by_id).to eq(nil)
            expect(lettings_log.assigned_to_id).to eq(user.id)
            task.invoke
            lettings_log.reload
            expect(lettings_log.created_by_id).to eq(user.id)
            expect(lettings_log.assigned_to_id).to eq(user.id)
            expect(lettings_log.updated_at).to eq(initial_updated_at)
          end

          it "sets created_by to assigned_to for sales" do
            initial_updated_at = sales_log.updated_at
            expect(sales_log.created_by_id).to eq(nil)
            expect(sales_log.assigned_to_id).to eq(user.id)
            task.invoke
            sales_log.reload
            expect(sales_log.created_by_id).to eq(user.id)
            expect(sales_log.assigned_to_id).to eq(user.id)
            expect(sales_log.updated_at).to eq(initial_updated_at)
          end
        end
      end
    end
  end
end
