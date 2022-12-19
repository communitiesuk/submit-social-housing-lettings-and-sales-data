class AddNeedstypeToBulkUpload < ActiveRecord::Migration[7.0]
  def change
    change_table :bulk_uploads, bulk: true do |t|
      t.column :needstype, :integer
    end
  end
end
