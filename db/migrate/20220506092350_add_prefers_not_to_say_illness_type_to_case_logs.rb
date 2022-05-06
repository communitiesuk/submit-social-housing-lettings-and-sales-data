class AddPrefersNotToSayIllnessTypeToCaseLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :case_logs, :illness_type_0, :integer
  end
end
