class IntegerFields < ActiveRecord::Migration[7.0]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :relat2
      t.column :relat2, :integer
      t.remove :relat3
      t.column :relat3, :integer
      t.remove :relat4
      t.column :relat4, :integer
      t.remove :relat5
      t.column :relat5, :integer
      t.remove :relat6
      t.column :relat6, :integer
      t.remove :relat7
      t.column :relat7, :integer
      t.remove :relat8
      t.column :relat8, :integer
      t.remove :rent_type
      t.column :rent_type, :integer
      t.remove :has_benefits
      t.column :has_benefits, :integer
      t.remove :renewal
      t.column :renewal, :integer
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.remove :relat2
      t.column :relat2, :string
      t.remove :relat3
      t.column :relat3, :string
      t.remove :relat4
      t.column :relat4, :string
      t.remove :relat5
      t.column :relat5, :string
      t.remove :relat6
      t.column :relat6, :string
      t.remove :relat7
      t.column :relat7, :string
      t.remove :relat8
      t.column :relat8, :string
      t.remove :rent_type
      t.column :rent_type, :string
      t.remove :has_benefits
      t.column :has_benefits, :string
      t.remove :renewal
      t.column :renewal, :string
    end
  end
end
