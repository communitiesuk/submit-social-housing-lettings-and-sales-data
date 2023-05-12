class AddNewOrganisationTelephoneNumberToMergeRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :merge_requests, :new_organisation_telephone_number, :string
  end
end
