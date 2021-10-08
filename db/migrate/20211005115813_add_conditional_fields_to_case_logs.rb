class AddConditionalFieldsToCaseLogs < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :outstanding_rent_or_charges, :string
      t.column :other_reason_for_leaving_last_settled_home, :string
      t.rename :last_settled_home, :reason_for_leaving_last_settled_home
    end
  end
end
