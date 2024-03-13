class AddUprnSelectionToLettingsLog < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :uprn_selection, :string
  end
end
