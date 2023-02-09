class AddInitialConfirmationSentToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :initial_confirmation_sent, :boolean
  end
end
