class DropOrganisationsLas < ActiveRecord::Migration[7.0]
  def up
    drop_table :organisation_las
  end

  def down
    create_table :organisation_las do |t|
      t.belongs_to :organisation
      t.column :ons_code, :string

      t.timestamps
    end
  end
end
