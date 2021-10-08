class AddConditionEffectsFields < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :condition_effects_vision, :boolean
      t.column :condition_effects_hearing, :boolean
      t.column :condition_effects_mobility, :boolean
      t.column :condition_effects_dexterity, :boolean
      t.column :condition_effects_stamina, :boolean
      t.column :condition_effects_learning, :boolean
      t.column :condition_effects_memory, :boolean
      t.column :condition_effects_mental_health, :boolean
      t.column :condition_effects_social_or_behavioral, :boolean
      t.column :condition_effects_other, :boolean
      t.column :condition_effects_prefer_not_to_say, :boolean
    end
  end
end
