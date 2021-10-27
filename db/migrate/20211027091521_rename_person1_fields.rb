class RenamePerson1Fields < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.rename :tenant_economic_status, :person_1_economic_status
    end
  end
end
