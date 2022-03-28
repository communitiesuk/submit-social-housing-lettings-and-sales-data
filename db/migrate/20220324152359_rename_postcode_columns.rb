class RenamePostcodeColumns < ActiveRecord::Migration[7.0]
  def change
    rename_column :case_logs, :previous_postcode, :ppostcode_full
    rename_column :case_logs, :property_postcode, :postcode_full
  end
end
