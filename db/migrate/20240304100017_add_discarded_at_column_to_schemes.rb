class AddDiscardedAtColumnToSchemes < ActiveRecord::Migration[7.0]
  def change
    add_column :schemes, :discarded_at, :datetime
  end
end
