class FixTypo < ActiveRecord::Migration[7.0]
  def up
    rename_column :case_logs, :letting_in_sheltered_accomodation, :letting_in_sheltered_accommodation
  end

  def down
    rename_column :case_logs, :letting_in_sheltered_accommodation, :letting_in_sheltered_accomodation
  end
end
