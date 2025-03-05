class AddNewQuestionFieldsToOrganisation < ActiveRecord::Migration[7.2]
  def change
    add_column :organisations, :profit_status, :integer
    add_column :organisations, :group_member, :boolean
    add_column :organisations, :group, :integer
  end
end
