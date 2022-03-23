class CreateDataProtectionConfirmation < ActiveRecord::Migration[7.0]
  def change
    create_table :data_protection_confirmations do |t|
      t.belongs_to :organisation
      t.belongs_to :data_protection_officer, class_name: "User", index: { name: :dpo_user_id }
      t.column :confirmed, :boolean

      t.timestamps
    end
  end
end
