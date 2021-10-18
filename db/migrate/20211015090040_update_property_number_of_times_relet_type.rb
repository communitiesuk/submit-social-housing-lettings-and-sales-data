class UpdatePropertyNumberOfTimesReletType < ActiveRecord::Migration[6.1]
  def change
    change_column :case_logs, :property_number_of_times_relet, :integer
  end
end
