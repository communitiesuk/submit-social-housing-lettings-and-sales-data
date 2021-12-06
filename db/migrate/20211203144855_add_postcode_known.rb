class AddPostcodeKnown < ActiveRecord::Migration[6.1]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :postcode_known, :integer
      t.column :la_known, :integer
    end
  end
end
