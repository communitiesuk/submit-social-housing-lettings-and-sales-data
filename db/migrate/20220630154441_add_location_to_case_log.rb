class AddLocationToCaseLog < ActiveRecord::Migration[7.0]
  def change
    add_reference :case_logs, :location, foreign_key: true
  end
end
