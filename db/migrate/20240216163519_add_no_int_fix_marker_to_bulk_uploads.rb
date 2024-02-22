class AddNoIntFixMarkerToBulkUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :noint_fix_status, :string, default: "not_applied"
  end
end
