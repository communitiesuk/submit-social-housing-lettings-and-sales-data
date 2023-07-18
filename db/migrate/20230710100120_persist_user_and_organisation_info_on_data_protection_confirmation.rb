class PersistUserAndOrganisationInfoOnDataProtectionConfirmation < ActiveRecord::Migration[7.0]
  def change
    change_table :data_protection_confirmations, bulk: true do |t|
      t.column :signed_at, :datetime
      t.column :organisation_name, :string
      t.column :organisation_address, :string
      t.column :organisation_phone_number, :string
      t.column :data_protection_officer_email, :string
      t.column :data_protection_officer_name, :string
    end
  end
end
