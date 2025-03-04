class AddCreatedByToCaseLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.belongs_to :created_by
    end
  end
end
