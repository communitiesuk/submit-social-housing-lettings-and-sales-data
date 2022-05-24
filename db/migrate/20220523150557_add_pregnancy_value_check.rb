class AddPregnancyValueCheck < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :pregnancy_value_check, :integer
  end
end
