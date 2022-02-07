class AddDeclaration < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :declaration, :integer
    end
  end
end
