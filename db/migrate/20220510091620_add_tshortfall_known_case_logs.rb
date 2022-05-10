class AddTshortfallKnownCaseLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :tshortfall_known, :integer
  end
end
