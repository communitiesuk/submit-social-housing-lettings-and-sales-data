class ChangeColumnTypes < ActiveRecord::Migration[6.1]
  def up
    change_table :case_logs, bulk: true do |t|
      t.change :first_time_property_let_as_social_housing, :string
      t.change :type_property_most_recently_let_as, :string
      t.change :builtype, :string
      t.change :do_you_know_the_local_authority, :string
      t.change :do_you_know_the_postcode, :string
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.change :first_time_property_let_as_social_housing, :int
      t.change :type_property_most_recently_let_as, :int
      t.change :builtype, :int
      t.change :do_you_know_the_local_authority, :int
      t.change :do_you_know_the_postcode, :int
    end
  end
end
