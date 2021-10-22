class ChangeFieldTypes < ActiveRecord::Migration[6.1]
  def up
    change_column :case_logs, :net_income, "integer USING CAST(property_number_of_times_relet AS integer)"
  end

  def down
    change_column :case_logs, :net_income, :string
  end
end
