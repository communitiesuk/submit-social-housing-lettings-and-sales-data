class ChangeFieldTypes < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.change :ethnic, "integer USING ethnic::integer"
      t.change :national, "integer USING national::integer"
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.change :ethnic, :string
      t.change :national, :string
    end
  end
end
