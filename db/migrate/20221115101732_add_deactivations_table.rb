class AddDeactivationsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :location_deactivations do |t|
      t.datetime :deactivation_date
      t.datetime :reactivation_date
      t.belongs_to :location
      t.timestamps
    end
  end
end
