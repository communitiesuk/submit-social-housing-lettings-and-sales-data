class AddEthnicGroup < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :ethnic_group, :integer
  end
end
