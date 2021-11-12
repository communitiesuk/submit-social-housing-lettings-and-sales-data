class ChangeCheckboxTypes < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.change :accessibility_requirements_prefer_not_to_say, "integer USING accessibility_requirements_prefer_not_to_say::integer"
      t.change :condition_effects_prefer_not_to_say, "integer USING condition_effects_prefer_not_to_say::integer"
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.change :accessibility_requirements_prefer_not_to_say, "boolean USING accessibility_requirements_prefer_not_to_say::boolean"
      t.change :condition_effects_prefer_not_to_say, "boolean USING condition_effects_prefer_not_to_say::boolean"
    end
  end
end
