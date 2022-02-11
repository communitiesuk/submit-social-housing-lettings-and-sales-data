class AddUnknownLettingAllocation < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :letting_allocation_unknown, :boolean
    end
  end
end
