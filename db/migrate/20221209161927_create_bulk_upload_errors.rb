class CreateBulkUploadErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_upload_errors do |t|
      t.references :bulk_upload

      t.text :cell
      t.text :row

      t.text :tenant_code
      t.text :property_ref

      t.text :field
      t.text :error

      t.timestamps
    end
  end
end
