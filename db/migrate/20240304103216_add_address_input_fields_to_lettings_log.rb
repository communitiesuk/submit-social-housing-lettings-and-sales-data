class AddAddressInputFieldsToLettingsLog < ActiveRecord::Migration[7.0]
  def change
    change_table :lettings_logs, bulk: true do |t|
      t.string :address_line1_input
      t.string :postcode_full_input
    end
  end
end
