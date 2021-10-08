class AddReasonablePreferenceReasonFields < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :reasonable_preference_reason_homeless, :boolean
      t.column :reasonable_preference_reason_unsatisfactory_housing, :boolean
      t.column :reasonable_preference_reason_medical_grounds, :boolean
      t.column :reasonable_preference_reason_avoid_hardship, :boolean
      t.column :reasonable_preference_reason_do_not_know, :boolean
    end
  end
end
