class RemoveDuplicateShelteredAccomodationColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :case_logs, :letting_in_sheltered_accommodation, :integer
  end
end
