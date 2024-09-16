class AddLastFailedAttempt < ActiveRecord::Migration[7.0]
  def change
    add_column :merge_requests, :last_failed_attempt, :datetime
  end
end
