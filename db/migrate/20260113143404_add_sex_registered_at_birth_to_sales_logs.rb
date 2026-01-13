class AddSexRegisteredAtBirthToSalesLogs < ActiveRecord::Migration[7.2]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :sexRAB1, :string
      t.column :sexRAB2, :string
      t.column :sexRAB3, :string
      t.column :sexRAB4, :string
      t.column :sexRAB5, :string
      t.column :sexRAB6, :string
    end
  end
end
