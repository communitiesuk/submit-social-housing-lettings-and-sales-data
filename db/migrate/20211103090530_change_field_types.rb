class ChangeFieldTypes < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.change :ethnic, "integer USING ethnic::integer"
      t.change :national, "integer USING national::integer"
      t.change :ecstat1, "integer USING ecstat1::integer"
      t.change :ecstat2, "integer USING ecstat2::integer"
      t.change :ecstat3, "integer USING ecstat3::integer"
      t.change :ecstat4, "integer USING ecstat4::integer"
      t.change :ecstat5, "integer USING ecstat5::integer"
      t.change :ecstat6, "integer USING ecstat6::integer"
      t.change :ecstat7, "integer USING ecstat7::integer"
      t.change :ecstat8, "integer USING ecstat8::integer"
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.change :ethnic, :string
      t.change :national, :string
      t.change :ecstat1, :string
      t.change :ecstat2, :string
      t.change :ecstat3, :string
      t.change :ecstat4, :string
      t.change :ecstat5, :string
      t.change :ecstat6, :string
      t.change :ecstat7, :string
      t.change :ecstat8, :string
    end
  end
end
