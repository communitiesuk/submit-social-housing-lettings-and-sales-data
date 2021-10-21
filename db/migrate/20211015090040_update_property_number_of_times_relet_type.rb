class UpdatePropertyNumberOfTimesReletType < ActiveRecord::Migration[6.1]
  def up
    change_column :case_logs, :property_number_of_times_relet, "integer USING CAST(property_number_of_times_relet AS integer)"
  end

  def down
    change_column :case_logs, :property_number_of_times_relet, :string
  end
end
