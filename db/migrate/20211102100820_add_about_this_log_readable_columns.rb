class AddAboutThisLogReadableColumns < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :gdpr_acceptance, :string
      t.column :gdpr_declined, :string
      t.column :property_owner_organisation, :string
      t.column :property_manager_organisation, :string
      t.column :sale_or_letting, :string
      t.column :tenant_same_property_renewal, :string
      t.column :rent_type, :string
      t.column :intermediate_rent_product_name, :string
      t.column :needs_type, :string
      t.column :sale_completion_date, :string
      t.column :purchaser_code, :string
    end
  end
end
