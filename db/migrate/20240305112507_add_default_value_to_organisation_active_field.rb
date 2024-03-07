class AddDefaultValueToOrganisationActiveField < ActiveRecord::Migration[7.0]
  def up
    change_column :organisations, :active, :boolean, default: true

    execute "UPDATE organisations
      SET active = true;"
  end

  def down
    change_column :organisations, :active, :boolean
  end
end
