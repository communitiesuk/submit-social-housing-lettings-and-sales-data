class RemoveSupportProviderColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :schemes, :support_services_provider, :integer
  end
end
