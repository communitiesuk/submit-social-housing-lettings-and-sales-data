class AddLocationPostcodeValueCheckToLettingsLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :lettings_logs, :location_postcode_value_check, :integer
  end
end
