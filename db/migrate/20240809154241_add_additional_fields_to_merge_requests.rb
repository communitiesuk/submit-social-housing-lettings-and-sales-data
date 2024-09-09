class AddAdditionalFieldsToMergeRequests < ActiveRecord::Migration[7.0]
  def change
    change_table :merge_requests, bulk: true do |t|
      t.integer :requester_id
      t.string :helpdesk_ticket
      t.integer :total_users
      t.integer :total_schemes
      t.integer :total_lettings_logs
      t.integer :total_sales_logs
      t.integer :total_stock_owners
      t.integer :total_managing_agents
      t.boolean :signed_dsa, default: false
      t.datetime :discarded_at
    end
  end
end
