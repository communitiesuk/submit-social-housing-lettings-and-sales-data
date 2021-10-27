class AddOtherTenancyTypeField < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :other_tenancy_type, :string
    end
  end
end
