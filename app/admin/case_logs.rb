ActiveAdmin.register CaseLog do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params do
    CaseLog.editable_fields
  end

  index do
    selectable_column
    id_column
    column :created_at
    column :updated_at
    column :status
    column :tenant_code
    column :property_postcode
    column :owning_organisation
    column :managing_organisation
    actions
  end
end
