class AddNewFieldCountry < ActiveRecord::Migration[7.2]
  def change
    add_column :lettings_logs, :country, :string
  end
end
