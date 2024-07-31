class RemoveNointFixStatus < ActiveRecord::Migration[7.0]
  def change
    remove_column :bulk_uploads, :noint_fix_status, :string, default: "not_applied"
  end
end
