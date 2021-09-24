class AddTenancyFieldsToCaseLog < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :tenancy_code, :string
      t.column :tenancy_start_date, :string
      t.column :starter_tenancy, :string
      t.column :fixed_term_tenancy, :string
      t.column :tenancy_type, :string
      t.column :letting_type, :string
      t.column :letting_provider, :string
      t.column :property_location, :string
      t.column :previous_postcode, :string
      t.column :property_relet, :string
      t.column :property_vacancy_reason, :string
      t.column :property_reference, :string
      t.column :property_unit_type, :string
      t.column :property_building_type, :string
      t.column :property_number_of_bedrooms, :string
      t.column :property_void_date, :string
      t.column :property_major_repairs, :string
      t.column :property_major_repairs_date, :string
      t.column :property_number_of_times_relet, :string
      t.column :property_wheelchair_accessible, :string
    end
  end
end
