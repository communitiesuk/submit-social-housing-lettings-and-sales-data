class UpdateCaseLogsFields < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.integer :old_form_id, :lar, :irproduct
      t.remove :day, :month, :year, :other_hhmemb, type: :integer
      t.remove :ppostc1, :ppostc2, type: :string
      t.rename :intermediate_rent_product_name, :irproduct_other
    end
  end
end
