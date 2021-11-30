class UserCaseLogsBelongToOrganisation < ActiveRecord::Migration[6.1]
  def up
    change_table :users, bulk: true do |t|
      t.remove :organisation
      t.belongs_to :organisation
    end
    change_table :case_logs, bulk: true do |t|
      t.belongs_to :owning_organisation, class_name: "Organisation"
      t.belongs_to :managing_organisation, class_name: "Organisation"
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.remove :organisation_id
      t.column :organisation, :string
    end
    change_table :case_logs, bulk: true do |t|
      t.remove :owning_organisation_id
      t.remove :managing_organisation_id
    end
  end
end
