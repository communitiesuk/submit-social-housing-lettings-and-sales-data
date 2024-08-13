class RemoveOtherMergingOrgField < ActiveRecord::Migration[7.0]
  def change
    remove_column :merge_requests, :other_merging_organisations, :string
  end
end
