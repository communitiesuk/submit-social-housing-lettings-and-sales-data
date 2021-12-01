class ChangeLettypeDerivedField < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :needs_type
      t.column :needstype, :integer
      t.remove :lettype
      t.column :lettype, :integer
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.column :needs_type, :string
      t.remove :needstype
      t.remove :lettype
      t.column :lettype, :string
    end
  end
end
