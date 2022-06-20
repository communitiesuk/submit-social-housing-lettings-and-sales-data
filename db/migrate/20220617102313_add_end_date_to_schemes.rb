class AddEndDateToSchemes < ActiveRecord::Migration[7.0]
  def change
    add_column :schemes, :end_date, :datetime
  end
end
