class CreateSchemes < ActiveRecord::Migration[7.0]
  def change
    create_table :schemes do |t|
      t.string :code null: false
      t.string :service
      t.bigint :organisation_id
      t.datetime :created_at

      t.timestamps
    end
  end
end
