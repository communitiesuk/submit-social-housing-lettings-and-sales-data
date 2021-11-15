class AddOtherMembersColumn < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :other_hhmemb, :integer
    end
  end
end
