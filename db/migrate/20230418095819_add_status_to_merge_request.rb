class AddStatusToMergeRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :merge_requests, :status, :integer
  end
end
