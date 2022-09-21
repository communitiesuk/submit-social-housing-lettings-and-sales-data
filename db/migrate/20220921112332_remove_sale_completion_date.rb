class RemoveSaleCompletionDate < ActiveRecord::Migration[7.0]
  def change
    remove_column :lettings_logs, :sale_completion_date, :datetime
  end
end
