class RenameOrgType < ActiveRecord::Migration[6.1]
  def change
    rename_column :organisations, :org_type, :providertype
  end
end
