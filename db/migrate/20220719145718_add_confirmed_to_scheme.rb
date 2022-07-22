class AddConfirmedToScheme < ActiveRecord::Migration[7.0]
  def change
    change_table :schemes, bulk: true do |t|
      t.column :confirmed, :boolean
    end
  end
end
