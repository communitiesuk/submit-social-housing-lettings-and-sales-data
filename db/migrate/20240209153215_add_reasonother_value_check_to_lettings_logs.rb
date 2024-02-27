class AddReasonotherValueCheckToLettingsLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :reasonother_value_check, :integer
  end
end
