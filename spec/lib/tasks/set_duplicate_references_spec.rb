require "rails_helper"
require "rake"

RSpec.describe "set_duplicate_references" do
  describe ":set_duplicate_references", type: :task do
    subject(:task) { Rake::Task["set_duplicate_references"] }

    before do
      Rake.application.rake_require("tasks/set_duplicate_references")
      Rake::Task.define_task(:environment)
      task.reenable
    end

    context "when the rake task is run" do
      context "and there are sales duplicates in 1 organisation" do
        let(:user) { create(:user) }
        let!(:sales_log) { create(:sales_log, :duplicate, created_by: user) }
        let!(:duplicate_sales_log) { create(:sales_log, :duplicate, created_by: user) }
        let!(:second_duplicate_sales_log) { create(:sales_log, :duplicate, created_by: user) }
        let!(:sales_log_without_duplicates) { create(:sales_log, created_by: user) }

        it "creates duplicate references for sales logs" do
          expect(sales_log.duplicates.count).to eq(0)
          expect(sales_log.duplicate_set_id).to be_nil
          expect(duplicate_sales_log.duplicates.count).to eq(0)
          expect(duplicate_sales_log.duplicate_set_id).to be_nil
          expect(second_duplicate_sales_log.duplicates.count).to eq(0)
          expect(second_duplicate_sales_log.duplicate_set_id).to be_nil
          expect(sales_log_without_duplicates.duplicates.count).to eq(0)
          expect(sales_log_without_duplicates.duplicate_set_id).to be_nil

          task.invoke
          sales_log.reload
          duplicate_sales_log.reload
          second_duplicate_sales_log.reload
          sales_log_without_duplicates.reload

          expect(sales_log.duplicates.count).to eq(2)
          expect(duplicate_sales_log.duplicates.count).to eq(2)
          expect(second_duplicate_sales_log.duplicates.count).to eq(2)
          expect(sales_log_without_duplicates.duplicates.count).to eq(0)
          expect(sales_log.duplicate_set_id).to eq(duplicate_sales_log.duplicate_set_id)
          expect(sales_log.duplicate_set_id).to eq(second_duplicate_sales_log.duplicate_set_id)
        end
      end

      context "and there are sales duplicates in multiple organisations" do
        let(:user) { create(:user) }
        let!(:sales_log) { create(:sales_log, :duplicate, created_by: user) }
        let!(:duplicate_sales_log) { create(:sales_log, :duplicate, created_by: user) }
        let!(:sales_log_without_duplicates) { create(:sales_log, created_by: user) }
        let(:other_user) { create(:user) }
        let!(:other_sales_log) { create(:sales_log, :duplicate, created_by: other_user) }
        let!(:other_duplicate_sales_log) { create(:sales_log, :duplicate, created_by: other_user) }
        let!(:other_sales_log_without_duplicates) { create(:sales_log, created_by: other_user) }

        it "creates separate duplicate references for sales logs" do
          expect(sales_log.duplicates.count).to eq(0)
          expect(sales_log.duplicate_set_id).to be_nil
          expect(duplicate_sales_log.duplicates.count).to eq(0)
          expect(duplicate_sales_log.duplicate_set_id).to be_nil
          expect(sales_log_without_duplicates.duplicates.count).to eq(0)
          expect(sales_log_without_duplicates.duplicate_set_id).to be_nil

          expect(other_sales_log.duplicates.count).to eq(0)
          expect(other_sales_log.duplicate_set_id).to be_nil
          expect(other_duplicate_sales_log.duplicates.count).to eq(0)
          expect(other_duplicate_sales_log.duplicate_set_id).to be_nil
          expect(other_sales_log_without_duplicates.duplicates.count).to eq(0)
          expect(other_sales_log_without_duplicates.duplicate_set_id).to be_nil

          task.invoke
          sales_log.reload
          duplicate_sales_log.reload
          sales_log_without_duplicates.reload
          other_sales_log.reload
          other_duplicate_sales_log.reload

          expect(sales_log.duplicates.count).to eq(1)
          expect(duplicate_sales_log.duplicates.count).to eq(1)
          expect(sales_log_without_duplicates.duplicates.count).to eq(0)
          expect(sales_log.duplicate_set_id).to eq(duplicate_sales_log.duplicate_set_id)

          expect(other_sales_log.duplicates.count).to eq(1)
          expect(other_duplicate_sales_log.duplicates.count).to eq(1)
          expect(other_sales_log_without_duplicates.duplicates.count).to eq(0)
          expect(other_sales_log.duplicate_set_id).to eq(other_duplicate_sales_log.duplicate_set_id)
          expect(other_sales_log.duplicate_set_id).not_to eq(sales_log.duplicate_set_id)
        end
      end

      context "and there are sales duplicates for non 2023/24 collection period" do
        let(:user) { create(:user) }
        let!(:sales_log) { create(:sales_log, :duplicate, created_by: user) }
        let!(:duplicate_sales_log) { create(:sales_log, :duplicate, created_by: user) }

        before do
          sales_log.saledate = Time.zone.local(2022, 4, 4)
          sales_log.save!(validate: false)
          duplicate_sales_log.saledate = Time.zone.local(2022, 4, 4)
          duplicate_sales_log.save!(validate: false)
        end

        it "does not create duplicate references for sales logs" do
          expect(sales_log.duplicates.count).to eq(0)
          expect(sales_log.duplicate_set_id).to be_nil
          expect(duplicate_sales_log.duplicates.count).to eq(0)
          expect(duplicate_sales_log.duplicate_set_id).to be_nil

          task.invoke
          sales_log.reload
          duplicate_sales_log.reload

          expect(sales_log.duplicates.count).to eq(0)
          expect(sales_log.duplicate_set_id).to be_nil
          expect(duplicate_sales_log.duplicates.count).to eq(0)
          expect(duplicate_sales_log.duplicate_set_id).to be_nil
        end
      end

      context "and there are lettings duplicates in 1 organisation" do
        let(:user) { create(:user) }
        let!(:lettings_log) { create(:lettings_log, :duplicate, created_by: user) }
        let!(:duplicate_lettings_log) { create(:lettings_log, :duplicate, created_by: user) }
        let!(:second_duplicate_lettings_log) { create(:lettings_log, :duplicate, created_by: user) }
        let!(:lettings_log_without_duplicates) { create(:lettings_log, created_by: user) }

        it "creates duplicate references for lettings logs" do
          expect(lettings_log.duplicates.count).to eq(0)
          expect(lettings_log.duplicate_set_id).to be_nil
          expect(duplicate_lettings_log.duplicates.count).to eq(0)
          expect(duplicate_lettings_log.duplicate_set_id).to be_nil
          expect(second_duplicate_lettings_log.duplicates.count).to eq(0)
          expect(second_duplicate_lettings_log.duplicate_set_id).to be_nil
          expect(lettings_log_without_duplicates.duplicates.count).to eq(0)
          expect(lettings_log_without_duplicates.duplicate_set_id).to be_nil

          task.invoke
          lettings_log.reload
          duplicate_lettings_log.reload
          second_duplicate_lettings_log.reload
          lettings_log_without_duplicates.reload

          expect(lettings_log.duplicates.count).to eq(2)
          expect(duplicate_lettings_log.duplicates.count).to eq(2)
          expect(second_duplicate_lettings_log.duplicates.count).to eq(2)
          expect(lettings_log_without_duplicates.duplicates.count).to eq(0)
          expect(lettings_log_without_duplicates.duplicate_set_id).to be_nil
          expect(lettings_log.duplicate_set_id).to eq(duplicate_lettings_log.duplicate_set_id)
          expect(lettings_log.duplicate_set_id).to eq(second_duplicate_lettings_log.duplicate_set_id)
        end
      end

      context "and there are lettings duplicates in multiple organisations" do
        let(:user) { create(:user) }
        let!(:lettings_log) { create(:lettings_log, :duplicate, created_by: user) }
        let!(:duplicate_lettings_log) { create(:lettings_log, :duplicate, created_by: user) }
        let!(:lettings_log_without_duplicates) { create(:lettings_log, created_by: user) }
        let(:other_user) { create(:user) }
        let!(:other_lettings_log) { create(:lettings_log, :duplicate, created_by: other_user) }
        let!(:other_duplicate_lettings_log) { create(:lettings_log, :duplicate, created_by: other_user) }
        let!(:other_lettings_log_without_duplicates) { create(:lettings_log, created_by: other_user) }

        it "creates separate duplicate references for lettings logs" do
          expect(lettings_log.duplicates.count).to eq(0)
          expect(lettings_log.duplicate_set_id).to be_nil
          expect(duplicate_lettings_log.duplicates.count).to eq(0)
          expect(duplicate_lettings_log.duplicate_set_id).to be_nil
          expect(lettings_log_without_duplicates.duplicates.count).to eq(0)
          expect(lettings_log_without_duplicates.duplicate_set_id).to be_nil

          expect(other_lettings_log.duplicates.count).to eq(0)
          expect(other_lettings_log.duplicate_set_id).to be_nil
          expect(other_duplicate_lettings_log.duplicates.count).to eq(0)
          expect(other_duplicate_lettings_log.duplicate_set_id).to be_nil
          expect(other_lettings_log_without_duplicates.duplicates.count).to eq(0)
          expect(other_lettings_log_without_duplicates.duplicate_set_id).to be_nil

          task.invoke
          lettings_log.reload
          duplicate_lettings_log.reload
          lettings_log_without_duplicates.reload
          other_lettings_log.reload
          other_duplicate_lettings_log.reload

          expect(lettings_log.duplicates.count).to eq(1)
          expect(duplicate_lettings_log.duplicates.count).to eq(1)
          expect(lettings_log_without_duplicates.duplicates.count).to eq(0)
          expect(lettings_log_without_duplicates.duplicate_set_id).to be_nil
          expect(lettings_log.duplicate_set_id).to eq(duplicate_lettings_log.duplicate_set_id)

          expect(other_lettings_log.duplicates.count).to eq(1)
          expect(other_duplicate_lettings_log.duplicates.count).to eq(1)
          expect(other_lettings_log_without_duplicates.duplicates.count).to eq(0)
          expect(other_lettings_log_without_duplicates.duplicate_set_id).to be_nil
          expect(other_lettings_log.duplicate_set_id).to eq(other_duplicate_lettings_log.duplicate_set_id)
          expect(other_lettings_log.duplicate_set_id).not_to eq(lettings_log.duplicate_set_id)
        end
      end

      context "and there are lettings duplicates for non 2023/24 collection period" do
        let(:user) { create(:user) }
        let!(:lettings_log) { create(:lettings_log, :duplicate, created_by: user) }
        let!(:duplicate_lettings_log) { create(:lettings_log, :duplicate, created_by: user) }

        before do
          lettings_log.startdate = Time.zone.local(2022, 4, 4)
          lettings_log.save!(validate: false)
          duplicate_lettings_log.startdate = Time.zone.local(2022, 4, 4)
          duplicate_lettings_log.save!(validate: false)
        end

        it "does not create duplicate references for lettings logs" do
          expect(lettings_log.duplicates.count).to eq(0)
          expect(lettings_log.duplicate_set_id).to be_nil
          expect(duplicate_lettings_log.duplicates.count).to eq(0)
          expect(duplicate_lettings_log.duplicate_set_id).to be_nil

          task.invoke
          lettings_log.reload
          duplicate_lettings_log.reload

          expect(lettings_log.duplicates.count).to eq(0)
          expect(lettings_log.duplicate_set_id).to be_nil
          expect(duplicate_lettings_log.duplicates.count).to eq(0)
          expect(duplicate_lettings_log.duplicate_set_id).to be_nil
        end
      end
    end
  end
end
