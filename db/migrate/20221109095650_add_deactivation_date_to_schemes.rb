class AddDeactivationDateToSchemes < ActiveRecord::Migration[7.0]
  def change
    add_column :schemes, :deactivation_date, :datetime
  end
end
