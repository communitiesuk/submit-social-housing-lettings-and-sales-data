class AddChoiceToBulkUpload < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :choice, :text, null: true
  end
end
