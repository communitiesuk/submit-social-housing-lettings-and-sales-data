class CreateOrganisationLa < ActiveRecord::Migration[7.0]
  def change
    create_table :organisation_las do |t|
      t.belongs_to :organisation
      t.column :ons_code, :string

      t.timestamps
    end
  end
end
