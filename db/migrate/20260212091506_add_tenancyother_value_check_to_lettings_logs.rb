class AddTenancyotherValueCheckToLettingsLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :tenancyother_value_check, :integer
  end
end
