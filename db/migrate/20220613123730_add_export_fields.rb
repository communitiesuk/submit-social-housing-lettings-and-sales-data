class AddExportFields < ActiveRecord::Migration[7.0]
  def change
    change_table :case_logs, bulk: true do |t|
      t.column :hhtype, :integer
      t.column :new_old, :integer
      t.column :vacdays, :integer
      t.rename :tenant_code, :tenancycode
      t.rename :previous_postcode_known, :ppcodenk
      t.rename :shelteredaccom, :sheltered
      t.remove :tenancy_code, type: :string
    end
  end
end
