ActiveAdmin.register User do
  permit_params :name, :email, :password, :password_confirmation, :organisation_id

  controller do
    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update_attributes : :update_without_password
      object.send(update_method, *attributes)
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :organisation
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :name
  filter :organisation
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :organisation
    end
    f.actions
  end
end
