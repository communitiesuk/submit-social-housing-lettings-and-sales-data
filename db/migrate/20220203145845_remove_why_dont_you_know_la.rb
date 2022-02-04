class RemoveWhyDontYouKnowLa < ActiveRecord::Migration[7.0]
  def up
    remove_column :case_logs, :why_dont_you_know_la
  end

  def down
    add_column :case_logs, :why_dont_you_know_la, :string
  end
end
