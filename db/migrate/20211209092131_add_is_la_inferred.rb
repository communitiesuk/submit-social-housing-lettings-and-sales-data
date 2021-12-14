class AddIsLaInferred < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :is_la_inferred, :boolean
    end
  end
end
