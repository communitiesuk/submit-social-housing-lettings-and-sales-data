class ChangeDpoToAttribute < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.column :is_dpo, :boolean, default: false
    end
  end
end
