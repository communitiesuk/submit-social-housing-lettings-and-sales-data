class AddCsvDownloadTable < ActiveRecord::Migration[7.0]
  def change
    create_table :csv_downloads do |t|
      t.column :download_type, :string
      t.column :filename, :string
      t.timestamps
      t.references :user
      t.references :organisation
    end
  end
end
