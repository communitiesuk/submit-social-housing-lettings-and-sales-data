class RemoveDataProtectionConfirmationUniqueIndex < ActiveRecord::Migration[7.0]
  def up
    remove_index :data_protection_confirmations,
                 %i[organisation_id data_protection_officer_id confirmed],
                 unique: true
  end

  def down
    add_index :data_protection_confirmations,
              %i[organisation_id data_protection_officer_id confirmed],
              unique: true,
              name: "data_protection_confirmations_unique"
  end
end
