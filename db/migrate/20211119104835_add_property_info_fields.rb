class AddPropertyInfoFields < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :first_time_property_let_as_social_housing, :int
      t.column :why_dont_you_know_la, :string
      t.column :type_property_most_recently_let_as, :string
      t.column :builtype, :string
    end
  end
end
