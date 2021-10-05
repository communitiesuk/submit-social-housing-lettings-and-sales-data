class AddConditionalFieldsToCaseLogs < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :outstanding_rent_or_charges, :string
    end
  end
end
