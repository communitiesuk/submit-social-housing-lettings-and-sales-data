class AddPreviousPostcodeKnown < ActiveRecord::Migration[7.0]
  change_table :case_logs, bulk: true do |t|
    t.column :previous_postcode_known, :integer
    t.column :previous_la_known, :integer
    t.column :is_previous_la_inferred, :boolean
  end
end
