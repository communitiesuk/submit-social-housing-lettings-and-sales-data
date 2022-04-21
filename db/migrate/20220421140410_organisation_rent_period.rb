class OrganisationRentPeriod < ActiveRecord::Migration[7.0]
  def change
    create_table :organisation_rent_periods do |t|
      t.belongs_to :organisation
      t.column :rent_period, :integer

      t.timestamps
    end
  end
end
