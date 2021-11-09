class ChangeReasonType < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.change :reason, "integer USING reason::integer"
      t.change :majorrepairs, "integer USING majorrepairs::integer"
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.change :reason, :string
      t.change :majorrepairs, :string
    end
  end
end
