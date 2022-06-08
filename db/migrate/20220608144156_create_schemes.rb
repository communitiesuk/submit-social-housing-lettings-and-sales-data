class CreateSchemes < ActiveRecord::Migration[7.0]
  def change
    create_table :schemes do |t|
      t.string :code
      t.string :service
      t.references :organisation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
