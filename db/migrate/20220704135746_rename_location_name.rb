class RenameLocationName < ActiveRecord::Migration[7.0]
  def change
    change_table :locations, bulk: true do |t|
      t.rename :address_line1, :name
      t.remove :address_line2, type: :string
    end
  end
end
