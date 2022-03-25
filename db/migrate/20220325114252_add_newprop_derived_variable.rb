class AddNewpropDerivedVariable < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :newprop, :integer
    end
  end
end
