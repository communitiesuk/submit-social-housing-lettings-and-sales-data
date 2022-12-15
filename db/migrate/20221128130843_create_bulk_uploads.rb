class CreateBulkUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_uploads do |t|
      t.references :user
      t.text :log_type, null: false
      t.integer :year, null: false
      t.uuid :identifier, null: false

      t.timestamps
    end

    add_index :bulk_uploads, :identifier, unique: true
  end
end
