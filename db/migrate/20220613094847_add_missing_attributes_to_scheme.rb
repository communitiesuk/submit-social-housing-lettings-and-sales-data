class AddMissingAttributesToScheme < ActiveRecord::Migration[7.0]
  def change
    change_table :schemes, bulk: true do |t|
      t.string   :primary_client_group
      t.string   :secondary_client_group
      t.integer  :sensitive
      t.integer  :total_units
      t.integer  :scheme_type
      t.integer  :registered_under_care_act
      t.integer  :support_type
      t.string   :intended_stay
    end
  end
end
