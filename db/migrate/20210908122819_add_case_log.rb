class AddCaseLog < ActiveRecord::Migration[6.1]
  def change
    create_table :case_logs do |t|
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
