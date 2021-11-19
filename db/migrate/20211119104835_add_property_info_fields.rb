class AddPropertyInfoFields < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :do_you_know_the_postcode, :integer
      t.column :do_you_know_the_local_authority, :integer
      t.column :why_dont_you_know_la, :string
      t.column :first_time_property_let_as_social_housing, :integer
      t.column :type_property_most_recently_let_as, :integer
      t.column :builtype, :integer
    end
  end
end
