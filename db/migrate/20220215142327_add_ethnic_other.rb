class AddEthnicOther < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :ethnic_other, :string
  end
end
