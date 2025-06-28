class AddNewQuestionFieldsToOrganisation < ActiveRecord::Migration[7.2]
  def change
    change_table :organisations, bulk: true do |t|
      t.integer :profit_status
      t.boolean :group_member
      t.integer :group_member_id
      t.integer :group
    end
  end
end
