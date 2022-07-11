class AddForeignKeyToUserOrganisation < ActiveRecord::Migration[7.0]
 
  def change
    add_reference :organisations, :users, foreign_key: true, on_delete: :cascade
  end
end

