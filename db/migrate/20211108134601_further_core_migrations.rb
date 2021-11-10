class FurtherCoreMigrations < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :condition_effects_prefer_not_to_say
      t.remove :reason_for_leaving_last_settled_home
      t.column :reason, :integer
      t.remove :property_reference
      t.column :propcode, :string
      t.remove :property_major_repairs
      t.column :majorrepairs, :integer
      t.remove :property_location
      t.column :la, :string
      t.remove :previous_la
      t.column :prevloc, :string
      t.remove :housing_benefit
      t.column :hb, :integer
      t.remove :outstanding_rent_or_charges
      t.column :hbrentshortfall, :integer
      t.remove :outstanding_amount
      t.column :tshortfall, :integer
      t.column :postcode, :string
      t.column :postcod2, :string
      t.column :ppostc1, :string
      t.column :ppostc2, :string
      t.remove :property_relet
      t.column :property_relet, :integer
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.column :condition_effects_prefer_not_to_say, :integer
      t.column :condition_effects_prefer_not_to_say, :integer
      t.column :reason_for_leaving_last_settled_home, :string
      t.remove :reason
      t.column :property_reference, :string
      t.remove :propcode
      t.column :property_major_repairs, :string
      t.remove :majorrepairs
      t.column :property_location, :string
      t.remove :la
      t.column :previous_la, :string
      t.remove :prevloc
      t.column :housing_benefit, :string
      t.remove :hb
      t.column :outstanding_rent_or_charges, :string
      t.remove :hbrentshortfall
      t.column :outstanding_amount, :string
      t.remove :tshortfall
      t.remove :postcode
      t.remove :postcod2
      t.remove :ppostc1
      t.remove :ppostc2
      t.remove :property_relet
      t.column :property_relet, :string
    end
  end
end
