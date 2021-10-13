class RemoveRedundantField < ActiveRecord::Migration[6.1]
  def up
    remove_column :case_logs, :prior_homelessness
  end

  def down
    add_column :case_logs, :prior_homelessness, :string
  end
end
