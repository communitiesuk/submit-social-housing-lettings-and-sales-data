class AddReferralField < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :referral, :integer
    end
  end
end
