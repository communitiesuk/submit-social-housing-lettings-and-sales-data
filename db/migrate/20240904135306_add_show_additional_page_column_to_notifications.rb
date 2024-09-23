class AddShowAdditionalPageColumnToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :show_additional_page, :boolean
  end
end
