class AddRentFieldsToCaseLog < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :net_income, :string
      t.column :net_income_frequency, :string
      t.column :net_income_uc_proportion, :string
      t.column :housing_benefit, :string
      t.column :rent_frequency, :string
      t.column :basic_rent, :string
      t.column :service_charge, :string
      t.column :personal_service_charge, :string
      t.column :support_charge, :string
      t.column :total_charge, :string
      t.column :outstanding_amount, :string
      t.column :time_lived_in_la, :string
      t.column :time_on_la_waiting_list, :string
      t.column :previous_la, :string
      t.column :property_postcode, :string
      t.column :reasonable_preference, :string
      t.column :reasonable_preference_reason, :string
      t.column :cbl_letting, :string
      t.column :chr_letting, :string
      t.column :cap_letting, :string
    end
  end
end
