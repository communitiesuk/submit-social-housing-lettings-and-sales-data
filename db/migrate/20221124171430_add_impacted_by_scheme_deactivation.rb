class AddImpactedBySchemeDeactivation < ActiveRecord::Migration[7.0]
  def up
    change_table :lettings_logs, bulk: true do |t|
      t.column :impacted_by_scheme_deactivation, :boolean
    end
  end

  def down
    change_table :lettings_logs, bulk: true do |t|
      t.remove :impacted_by_scheme_deactivation
    end
  end
end
