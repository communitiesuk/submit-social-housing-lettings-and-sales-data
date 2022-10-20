class RenameManagingAgentsColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :organisations, :managing_agents, :managing_agents_label
  end
end
