class AddOrganisationIdToBulkUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :organisation_id, :integer
  end
end
