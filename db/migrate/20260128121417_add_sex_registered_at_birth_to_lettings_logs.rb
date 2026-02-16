class AddSexRegisteredAtBirthToLettingsLogs < ActiveRecord::Migration[7.2]
  def change
    change_table :lettings_logs, bulk: true do |t|
      t.column :sexrab1, :string
      t.column :sexrab2, :string
      t.column :sexrab3, :string
      t.column :sexrab4, :string
      t.column :sexrab5, :string
      t.column :sexrab6, :string
      t.column :sexrab7, :string
      t.column :sexrab8, :string
    end
  end
end
