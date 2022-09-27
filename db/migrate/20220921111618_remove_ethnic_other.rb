class RemoveEthnicOther < ActiveRecord::Migration[7.0]
  def change
    remove_column :lettings_logs, :ethnic_other, :string
  end
end
