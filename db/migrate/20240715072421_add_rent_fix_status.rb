class AddRentFixStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :rent_type_fix_status, :string, default: "not_applied"
  end
end
