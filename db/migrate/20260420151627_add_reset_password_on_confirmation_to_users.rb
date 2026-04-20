class AddResetPasswordOnConfirmationToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :reset_password_on_confirmation, :boolean, default: false
  end
end
