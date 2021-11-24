class ChangeRecentlyLetAsToEnum < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :type_property_most_recently_let_as
      t.column :unitletas, :int
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.remove :unitletas
      t.column :type_property_most_recently_let_as, :string
    end
  end
end
