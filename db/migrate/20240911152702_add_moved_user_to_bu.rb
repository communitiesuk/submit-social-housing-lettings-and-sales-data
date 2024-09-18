class AddMovedUserToBu < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_uploads, :moved_user_id, :integer
  end
end
