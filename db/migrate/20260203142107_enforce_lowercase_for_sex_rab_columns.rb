class EnforceLowercaseForSexRabColumns < ActiveRecord::Migration[7.2]
  def change
    rename_column :sales_logs, :"sexRAB1", :sexrab1
    rename_column :sales_logs, :"sexRAB2", :sexrab2
    rename_column :sales_logs, :"sexRAB3", :sexrab3
    rename_column :sales_logs, :"sexRAB4", :sexrab4
    rename_column :sales_logs, :"sexRAB5", :sexrab5
    rename_column :sales_logs, :"sexRAB6", :sexrab6
  end
end
