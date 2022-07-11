class AddSupportServicesProviderToSchemes < ActiveRecord::Migration[7.0]
  def change
    add_column :schemes, :support_services_provider, :integer
  end
end
