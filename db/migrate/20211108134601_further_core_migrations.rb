class FurtherCoreMigrations < ActiveRecord::Migration[6.1]
  def up
    remove_column :case_logs, :condition_effects_prefer_not_to_say
    rename_column :case_logs, :reason_for_leaving_last_settled_home, :reason
    rename_column :case_logs, :property_reference, :propcode
    rename_column :case_logs, :property_major_repairs, :majorrepairs
    add_column :case_logs, :postcode, :string
    add_column :case_logs, :postcod2, :string
  end

  def down
    add_column :case_logs, :condition_effects_prefer_not_to_say, :integer
    rename_column :case_logs, :reason, :reason_for_leaving_last_settled_home
    rename_column :case_logs, :propcode, :property_reference
    rename_column :case_logs, :majorrepairs, :property_major_repairs
    remove_column :case_logs, :postcode
    remove_column :case_logs, :postcod2
  end
end
