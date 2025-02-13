class AddDataSharingAgreement < ActiveRecord::Migration[7.0]
  def change
    create_table :data_sharing_agreements do |t|
      t.belongs_to :organisation
      t.belongs_to :data_protection_officer

      t.datetime :signed_at, null: false
      t.string :organisation_name, null: false
      t.string :organisation_address, null: false
      t.string :organisation_phone_number
      t.string :dpo_email, null: false
      t.string :dpo_name, null: false

      t.timestamps
    end

    add_index :data_sharing_agreements,
              %i[organisation_id data_protection_officer_id],
              unique: true,
              name: "data_sharing_agreements_unique"
  end
end
