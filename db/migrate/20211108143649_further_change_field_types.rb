class FurtherChangeFieldTypes < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.change :reason, "integer USING reason::integer"
      t.change :majorrepairs, "integer USING majorrepairs::integer"
      t.change :hb, "integer USING hb::integer"
      t.change :hbrentshortfall, "integer USING hbrentshortfall::integer"
      t.change :tshortfall, "integer USING tshortfall::integer"
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.change :reason, :string
      t.change :majorrepairs, :string
      t.change :hb, :string
      t.change :hbrentshortfall, :string
      t.change :tshortfall, :string
    end
  end
end
