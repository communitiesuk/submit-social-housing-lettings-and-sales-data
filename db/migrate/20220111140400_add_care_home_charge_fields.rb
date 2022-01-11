class AddCareHomeChargeFields < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :is_carehome, :integer
      t.column :chcharge, :decimal
    end
  end
end
