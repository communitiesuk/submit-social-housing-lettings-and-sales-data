class AddYearToExport < ActiveRecord::Migration[7.0]
  def change
    add_column :exports, :year, :integer
  end
end
