class RemoveGdprFields < ActiveRecord::Migration[7.0]
  def up
    change_table :case_logs, bulk: true do |t|
      t.remove :gdpr_declined
      t.remove :gdpr_acceptance
    end
  end

  def down
    change_table :case_logs, bulk: true do |t|
      t.column :gdpr_declined, :string
      t.column :gdpr_acceptance, :string
    end
  end
end
