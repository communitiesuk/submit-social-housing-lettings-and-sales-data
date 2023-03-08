class CreateLocalAuthorities < ActiveRecord::Migration[7.0]
  def change
    create_table :local_authorities do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date
      t.boolean :previous_location_only, default: false
      t.index %w[code], name: "index_local_authority_code", unique: true

      t.timestamps
    end
  end
end
