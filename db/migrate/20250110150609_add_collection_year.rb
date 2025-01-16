class AddCollectionYear < ActiveRecord::Migration[7.2]
  def change
    add_column :log_validations, :collection_year, :string
  end
end
