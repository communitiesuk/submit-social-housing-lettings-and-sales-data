class RenamePurchaserCode < ActiveRecord::Migration[7.0]
  def change
    rename_column :bulk_upload_errors, :purchase_code, :purchaser_code
  end
end
