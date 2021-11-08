class FurtherCoreMigrations < ActiveRecord::Migration[6.1]
  def up
    remove_column :case_logs, :condition_effects_prefer_not_to_say
    rename_column :case_logs, :reason_for_leaving_last_settled_home, :reason
  end

  def down
    add_column :case_logs, :condition_effects_prefer_not_to_say, :integer
    rename_column :case_logs, :reason, :reason_for_leaving_last_settled_home
  end
end
