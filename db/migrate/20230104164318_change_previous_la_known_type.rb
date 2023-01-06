class ChangePreviousLaKnownType < ActiveRecord::Migration[7.0]
  def up
    change_table :sales_logs, bulk: true do |t|
      t.change :previous_la_known, "integer USING previous_la_known::integer"
    end
  end

  def down
    change_table :sales_logs, bulk: true do |t|
      t.change :previous_la_known, "boolean USING previous_la_known::boolean"
    end
  end
end
