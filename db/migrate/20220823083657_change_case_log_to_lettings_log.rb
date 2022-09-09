class ChangeCaseLogToLettingsLog < ActiveRecord::Migration[7.0]
  def change
    rename_table :case_logs, :lettings_logs
  end
end
