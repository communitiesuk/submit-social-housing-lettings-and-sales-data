class AddCarehomeChargesValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :carehome_charges_value_check, :integer
  end
end
