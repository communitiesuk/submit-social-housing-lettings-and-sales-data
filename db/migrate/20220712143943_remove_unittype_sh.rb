class RemoveUnittypeSh < ActiveRecord::Migration[7.0]
  def change
    remove_column :case_logs, :unittype_sh, :integer
  end
end
