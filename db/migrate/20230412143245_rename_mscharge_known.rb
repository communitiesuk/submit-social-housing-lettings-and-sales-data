class RenameMschargeKnown < ActiveRecord::Migration[7.0]
  def change
    rename_column :sales_logs, :mscharge_known, :has_mscharge
  end
end
