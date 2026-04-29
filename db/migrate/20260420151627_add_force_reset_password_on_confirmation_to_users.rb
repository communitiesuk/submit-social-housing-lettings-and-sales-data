class AddForceResetPasswordOnConfirmationToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :force_reset_password_on_confirmation, :boolean, default: false
  end
end
