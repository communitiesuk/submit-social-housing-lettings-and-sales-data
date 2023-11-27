class AddMergeDateToSchemes < ActiveRecord::Migration[7.0]
  def change
    add_column :schemes, :merge_date, :datetime
  end
end
