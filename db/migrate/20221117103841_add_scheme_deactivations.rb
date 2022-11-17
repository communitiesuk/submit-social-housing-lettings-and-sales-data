class AddSchemeDeactivations < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_deactivation_periods do |t|
      t.datetime :deactivation_date
      t.datetime :reactivation_date
      t.belongs_to :scheme
      t.timestamps
    end
  end
end
