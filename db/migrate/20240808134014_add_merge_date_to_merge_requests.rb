class AddMergeDateToMergeRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :merge_requests, :merge_date, :datetime
  end
end
