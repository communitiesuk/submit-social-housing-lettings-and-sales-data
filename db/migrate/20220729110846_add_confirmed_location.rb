class AddConfirmedLocation < ActiveRecord::Migration[7.0]
  def change
    change_table :locations, bulk: true do |t|
      t.column :confirmed, :boolean
    end
  end
end
