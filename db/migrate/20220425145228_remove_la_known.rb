class RemoveLaKnown < ActiveRecord::Migration[7.0]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :la_known
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.column :la_known, :integer
    end
  end
end
