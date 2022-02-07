class AdditionalUserFields < ActiveRecord::Migration[7.0]
  def up
    change_table :users, bulk: true do |t|
      t.column :old_user_id, :string
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.remove :old_user_id
    end
  end
end
