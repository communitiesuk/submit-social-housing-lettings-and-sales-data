require "rails_helper"

RSpec.describe BulkUpload, type: :model do
  let(:bulk_upload) { create(:bulk_upload, log_type: "lettings") }

  describe "def bulk_upload.completed?" do
    context "when there are incomplete logs" do
      it "returns false" do
        create_list(:lettings_log, 2, :in_progress, bulk_upload:)
        expect(bulk_upload.completed?).to equal(false)
      end
    end

    context "when there are no incomplete logs" do
      it "returns true" do
        create_list(:lettings_log, 2, :completed, :startdate_today, bulk_upload:)
        expect(bulk_upload.completed?).to equal(true)
      end
    end
  end

  describe "value check clearing" do
    context "with a lettings log bulk upload" do
      let(:log) { create(:lettings_log, :startdate_today, bulk_upload:) }

      it "has the correct number of value checks to be set as confirmed" do
        expect(bulk_upload.fields_to_confirm(log)).to match_array %w[rent_value_check void_date_value_check major_repairs_date_value_check pregnancy_value_check retirement_value_check referral_value_check net_income_value_check carehome_charges_value_check scharge_value_check pscharge_value_check supcharg_value_check address_search_value_check multiple_partners_value_check partner_under_16_value_check reasonother_value_check]
      end
    end

    context "with a sales log bulk upload" do
      let(:log) { create(:sales_log, :saledate_today, bulk_upload:) }

      it "has the correct number of value checks to be set as confirmed" do
        expect(bulk_upload.fields_to_confirm(log)).to match_array %w[value_value_check monthly_charges_value_check percentage_discount_value_check income1_value_check income2_value_check combined_income_value_check retirement_value_check old_persons_shared_ownership_value_check buyer_livein_value_check student_not_child_value_check wheel_value_check mortgage_value_check savings_value_check deposit_value_check staircase_bought_value_check stairowned_value_check hodate_check shared_ownership_deposit_value_check extrabor_value_check grant_value_check discounted_sale_value_check deposit_and_mortgage_value_check address_search_value_check multiple_partners_value_check partner_under_16_value_check]
      end
    end
  end
end
