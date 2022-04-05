class CreateLogsExport < ActiveRecord::Migration[7.0]
  def change
    create_table :logs_exports do |t|
      t.integer :daily_run_number

      t.datetime :created_at, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
