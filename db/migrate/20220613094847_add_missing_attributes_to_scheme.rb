class AddMissingAttributesToScheme < ActiveRecord::Migration[7.0]
  def change
    add_column :schemes, :primary_client_group, :string
    add_column :schemes, :secondary_client_group, :string
    add_column :schemes, :sensitive, :boolean
    add_column :schemes, :total_units, :boolean
    add_column :schemes, :scheme_type, :integer
    add_column :schemes, :registered_under_care_act, :boolean
    add_column :schemes, :support_type, :integer
    add_column :schemes, :intended_stay, :string
  end
end
