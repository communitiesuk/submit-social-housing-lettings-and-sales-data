class RenameProviderType < ActiveRecord::Migration[7.0]
  def up
    rename_column :organisations, :providertype, :provider_type
  end

  def down
    rename_column :organisations, :provider_type, :providertype
  end
end
