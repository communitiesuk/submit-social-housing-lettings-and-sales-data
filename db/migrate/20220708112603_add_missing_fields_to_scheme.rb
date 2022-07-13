class AddMissingFieldsToScheme < ActiveRecord::Migration[7.0]
  def change
    change_table :schemes, bulk: true do |t|
      t.column :arrangement_type, :string
      t.column :old_id, :string
      t.column :old_visible_id, :integer
    end
  end
end
