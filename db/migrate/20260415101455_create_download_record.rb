class CreateDownloadRecord < ActiveRecord::Migration[7.2]
  def change
    create_table :download_records do |t|
      t.integer :download_type, null: false
      t.string :download_filters, null: false
      t.references :user, null: false, foreign_key: true
      t.references :user_organisation, null: false, foreign_key: { to_table: :organisations }
      t.integer :user_role, null: false

      t.timestamps
    end
  end
end
