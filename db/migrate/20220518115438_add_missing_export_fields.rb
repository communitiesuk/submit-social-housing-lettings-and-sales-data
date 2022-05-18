class AddMissingExportFields < ActiveRecord::Migration[7.0]
  def change
    change_table :logs_exports, bulk: true do |t|
      t.column :base_number, :integer, default: 1, null: false
      t.column :increment_number, :integer, default: 1, null: false
      t.remove :daily_run_number, type: :integer
    end
  end
end
