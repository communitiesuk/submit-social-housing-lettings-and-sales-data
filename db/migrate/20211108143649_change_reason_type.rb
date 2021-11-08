class ChangeReasonType < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.change :reason, "integer USING reason::integer"
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.change :reason, :string
    end
  end
end
