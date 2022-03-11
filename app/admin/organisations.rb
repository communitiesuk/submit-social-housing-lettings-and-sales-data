ActiveAdmin.register Organisation do
  permit_params do
    permitted = %i[name
                   phone
                   provider_type
                   address_line1
                   address_line2
                   postcode
                   local_authorities
                   holds_own_stock
                   other_stock_owners
                   managing_agents]
    permitted
  end

  index do
    selectable_column
    id_column
    column :name
    column "Org type", :provider_type
    column "Address Line 1", :address_line1
    column "Address Line 2", :address_line2
    column :postcode
    column "Phone Number", :phone
    column :local_authorities
    column :holds_own_stock
    column :other_stock_owners
    column :managing_agents
    actions
  end
end
