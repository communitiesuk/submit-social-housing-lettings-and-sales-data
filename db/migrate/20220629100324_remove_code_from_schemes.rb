class RemoveCodeFromSchemes < ActiveRecord::Migration[7.0]
  def change
    remove_column :schemes, :code, :string
  end
end
