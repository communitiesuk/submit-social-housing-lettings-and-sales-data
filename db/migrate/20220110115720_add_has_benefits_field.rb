class AddHasBenefitsField < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :has_benefits, :string
    end
  end
end
