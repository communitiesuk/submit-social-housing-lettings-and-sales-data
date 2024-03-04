class AddAddressInputFieldsToLettingsLog < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :address_line1_input, :string
    add_column :lettings_logs, :postcode_full_input, :string
  end
end
