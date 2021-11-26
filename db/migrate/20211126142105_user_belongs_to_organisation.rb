class UserBelongsToOrganisation < ActiveRecord::Migration[6.1]
  def up
    change_table :users, bulk: true do |t|
      t.remove :organisation
      t.belongs_to :organisation
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.remove :organisation_id
      t.column :organisation, :string
    end
  end
end
