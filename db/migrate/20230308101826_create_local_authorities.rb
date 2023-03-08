class CreateLocalAuthorities < ActiveRecord::Migration[7.0]
  def change
    create_table :local_authorities do |t|
      t.string :code
      t.string :la_name
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :previous_location_only, default: false

      t.timestamps
    end
  end
end
