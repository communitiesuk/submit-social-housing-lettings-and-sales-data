class AddNochargeField < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :nocharge, :integer
    end
  end
end
