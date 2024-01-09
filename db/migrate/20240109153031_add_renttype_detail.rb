class AddRenttypeDetail < ActiveRecord::Migration[7.0]
  def change
    add_column :lettings_logs, :renttype_detail, :integer
  end
end
