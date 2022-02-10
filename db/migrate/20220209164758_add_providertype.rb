class AddProvidertype < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :providertype, :integer
    end
  end
end
