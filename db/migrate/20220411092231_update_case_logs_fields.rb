class UpdateCaseLogsFields < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.integer :old_form_id, :lar, :irproduct
      t.remove :day, :month, :year, :vday, :vmonth, :vyear, :mrcday, :mrcmonth, :mrcyear, :other_hhmemb, :accessibility_requirements_prefer_not_to_say, :landlord, type: :integer
      t.remove :ppostc1, :ppostc2, :postcode, :postcod2, type: :string
      t.rename :intermediate_rent_product_name, :irproduct_other
      t.rename :lawaitlist, :waityear
      t.rename :other_reason_for_leaving_last_settled_home, :reasonother
      t.rename :property_void_date, :voiddate
    end
  end
end
