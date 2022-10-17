class CreateLocalAuthorities < ActiveRecord::Migration[7.0]
  def change
    create_table :local_authorities do |t|
      t.string :ons_code, null: false
      t.string :name, null: false

      t.index %i[ons_code name], unique: true # Only one entry per LA
      t.timestamps
    end
  end
end
