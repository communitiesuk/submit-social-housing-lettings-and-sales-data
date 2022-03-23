class CreateDataProtectionConfirmation < ActiveRecord::Migration[7.0]
  def change
    create_table :data_protection_confirmations do |t|
      t.belongs_to :organisation
      t.belongs_to :data_protection_officer, class_name: "User", index: { name: :dpo_user_id }
      t.column :confirmed, :boolean
      t.column :old_id, :string
      t.column :old_org_id, :string

      t.timestamps
    end

    add_index :data_protection_confirmations,
              %i[organisation_id data_protection_officer_id confirmed],
              unique: true,
              name: "data_protection_confirmations_unique"
  end
end
