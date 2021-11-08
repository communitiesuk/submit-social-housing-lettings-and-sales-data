class RemainingCoreMigrations < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |_t|
      remove_column :case_logs, :condition_effects_prefer_not_to_say
    end
  end

  def down
    change_table :case_logs, bulk: true do |_t|
      add_column :case_logs, :condition_effects_prefer_not_to_say, :integer
    end
  end
end
