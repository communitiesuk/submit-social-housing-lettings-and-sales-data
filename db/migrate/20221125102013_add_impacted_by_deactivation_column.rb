class AddImpactedByDeactivationColumn < ActiveRecord::Migration[7.0]
  def change
    change_table :lettings_logs, bulk: true do |t|
      t.column :unresolved, :boolean
    end
  end
end
