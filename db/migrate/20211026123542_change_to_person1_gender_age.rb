class ChangeToPerson1GenderAge < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.rename :tenant_age, :person_1_age
      t.rename :tenant_gender, :person_1_gender
    end
  end
end
