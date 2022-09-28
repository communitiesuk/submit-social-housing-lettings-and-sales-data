class LogsImports < ActiveRecord::Migration[7.0]
  def change
    create_table :logs_imports do |t|
      t.string :run_id, null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :duration_seconds, default: 0
      t.integer :total, default: 0 # Total logs to import in batch
      t.integer :num_saved, default: 0
      t.integer :num_skipped, default: 0

      t.jsonb :discrepancies # List of files with errors, etc
      t.jsonb :filenames # List of filenames processed

      t.timestamps
    end    
  end
end
