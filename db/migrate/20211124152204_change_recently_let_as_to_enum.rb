class ChangeRecentlyLetAsToEnum < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :type_property_most_recently_let_as
      t.column :unitletas, :int
      t.remove :builtype
      t.column :builtype, :int
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.remove :unitletas
      t.column :type_property_most_recently_let_as, :string
      t.remove :builtype
      t.remove :builtype, :string
    end
  end
end
