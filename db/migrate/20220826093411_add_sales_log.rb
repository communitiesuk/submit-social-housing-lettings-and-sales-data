class AddSalesLog < ActiveRecord::Migration[7.0]
  def change
    create_table :sales_logs do |t|
      t.integer :status, default: 0
      t.datetime :saledate
      t.timestamps
      t.references :owning_organisation, class_name: "Organisation", foreign_key: { to_table: :organisations, on_delete: :cascade }
      t.references :managing_organisation, class_name: "Organisation", foreign_key: { to_table: :organisations }
      t.references :created_by, class_name: "User", foreign_key: { to_table: :users }
    end
  end
end
