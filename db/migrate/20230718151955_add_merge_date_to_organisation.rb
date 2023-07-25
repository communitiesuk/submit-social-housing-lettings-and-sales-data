class AddMergeDateToOrganisation < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :merge_date, :datetime
  end
end
