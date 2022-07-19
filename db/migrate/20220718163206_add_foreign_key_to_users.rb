class AddForeignKeyToUsers < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :users, :organisations, on_delete: :cascade
  end
end
