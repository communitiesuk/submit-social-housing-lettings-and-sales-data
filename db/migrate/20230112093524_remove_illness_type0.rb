class RemoveIllnessType0 < ActiveRecord::Migration[7.0]
  def change
    remove_column :lettings_logs, :illness_type_0, :integer
  end
end
