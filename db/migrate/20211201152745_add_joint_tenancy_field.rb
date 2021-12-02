class AddJointTenancyField < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :joint_tenancy, :integer
    end
  end
end
