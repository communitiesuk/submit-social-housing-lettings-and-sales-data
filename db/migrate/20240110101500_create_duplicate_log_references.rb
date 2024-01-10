class CreateDuplicateLogReferences < ActiveRecord::Migration[7.0]
  def change
    create_table :duplicate_log_references do |t|
      t.integer :duplicate_log_reference_id
      t.integer :log_id
      t.string :log_type

      t.timestamps
    end
  end
end
