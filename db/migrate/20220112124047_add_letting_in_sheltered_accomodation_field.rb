class AddLettingInShelteredAccomodationField < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :letting_in_sheltered_accomodation, :integer
    end
  end
end
