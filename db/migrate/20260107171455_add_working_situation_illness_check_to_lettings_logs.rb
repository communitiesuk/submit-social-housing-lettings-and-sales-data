class AddWorkingSituationIllnessCheckToLettingsLogs < ActiveRecord::Migration[7.2]
  def change
    add_column :lettings_logs, :working_situation_illness_check, :integer
  end
end
