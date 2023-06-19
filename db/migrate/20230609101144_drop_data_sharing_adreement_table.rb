class DropDataSharingAdreementTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :data_sharing_agreements # rubocop:disable Rails/ReversibleMigration
  end
end
