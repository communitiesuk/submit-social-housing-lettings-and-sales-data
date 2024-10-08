class AddCollectionResourcesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :collection_resources do |t|
      t.column :log_type, :string
      t.column :resource_type, :string
      t.column :display_name, :string
      t.column :short_display_name, :string
      t.column :year, :integer
      t.column :download_filename, :string
      t.column :mandatory, :boolean
      t.column :released_to_user, :boolean
      t.timestamps
    end
  end
end
