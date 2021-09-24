class AddAdditionalFieldsToCaseLog < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :homelessness, :string
    end
  end
end
