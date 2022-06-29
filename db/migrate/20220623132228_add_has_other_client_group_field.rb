class AddHasOtherClientGroupField < ActiveRecord::Migration[7.0]
  def change
    change_table :schemes, bulk: true do |t|
      t.column :has_other_client_group, :integer
    end
  end
end
