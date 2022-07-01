class AddReferenceToCaseLog < ActiveRecord::Migration[7.0]
  def change
    add_reference :case_logs, :scheme, foreign_key: true, null: true
  end
end
