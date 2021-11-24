class ChangeArmedForces < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :armed_forces
      t.remove :armed_forces_partner
      t.column :armedforces, :integer
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.remove :armedforces
      t.column :armed_forces, :string
      t.column :armed_forces_partner, :string
    end
  end
end
