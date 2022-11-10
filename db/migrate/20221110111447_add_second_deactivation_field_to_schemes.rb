class AddSecondDeactivationFieldToSchemes < ActiveRecord::Migration[7.0]
  def change
    change_table :schemes, bulk: true do |t|
      t.column :deactivation_date_type, :integer
    end
  end
end
