class AddPostcodeToSalesLog < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs, bulk: true do |t|
      t.column :postcode_full, :string, default: nil # e.g. SE27 0HG
      t.column :pcode1, :string, default: nil # Outcode e.g. SE27
      t.column :pcode2, :string, default: nil # Incode e.g. 0HG
      t.column :pcodenk, :boolean, default: true # Not Known
    end
  end
end
