class AddDefaultValueToOrganisationActiveField < ActiveRecord::Migration[7.0]
  def change
    change_column :organisations, :active, :boolean, :default => true

    execute "UPDATE organisations
      SET active = true;"
  end
end
