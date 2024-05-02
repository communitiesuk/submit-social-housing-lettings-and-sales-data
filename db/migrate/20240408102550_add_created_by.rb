class AddCreatedBy < ActiveRecord::Migration[7.0]
  def change
    change_table :sales_logs do |t|
      t.references :created_by, class_name: "User"
    end

    change_table :lettings_logs do |t|
      t.references :created_by, class_name: "User"
    end
  end
end
