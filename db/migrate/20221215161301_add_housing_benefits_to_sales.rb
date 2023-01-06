class AddHousingBenefitsToSales < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :hb, :integer
    end
  end
end
