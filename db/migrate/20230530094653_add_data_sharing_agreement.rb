class AddDataSharingAgreement < ActiveRecord::Migration[7.0]
  def change
    create_table :data_sharing_agreements do |t|
      t.belongs_to :organisation
      t.belongs_to :data_protection_officer, class_name: "User"

      t.datetime :signed_at, null: false

      t.timestamps
    end

    add_index :data_sharing_agreements,
              %i[organisation_id data_protection_officer_id],
              unique: true,
              name: "data_sharing_agreements_unique"
  end
end
