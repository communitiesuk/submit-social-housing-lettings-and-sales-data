class AdditionalUserFields2 < ActiveRecord::Migration[7.0]
  def up
    change_table :users, bulk: true do |t|
      t.column :phone, :string
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.remove :phone
    end
  end
end
