class ChangeUnknownLettingAllocationType < ActiveRecord::Migration[7.0]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :letting_allocation_unknown
      t.column :letting_allocation_unknown, :integer
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.remove :letting_allocation_unknown
      t.column :letting_allocation_unknown, :boolean
    end
  end
end
