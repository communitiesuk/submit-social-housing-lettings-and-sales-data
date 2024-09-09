class UpdateMergeRequestFieldsForStatus < ActiveRecord::Migration[7.0]
  def up
    change_table :merge_requests, bulk: true do |t|
      t.column :request_merged, :boolean
      t.column :processing, :boolean
      t.remove :status
    end
  end

  def down
    change_table :merge_requests, bulk: true do |t|
      t.remove :request_merged
      t.remove :processing
      t.column :status, :string
    end
  end
end
