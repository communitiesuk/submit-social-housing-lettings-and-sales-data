class AddSupportServicesProviderForCoordinatorToSchemes < ActiveRecord::Migration[7.0]
  def change
    add_column :schemes, :support_services_provider_for_coordinator, :integer
  end
end
