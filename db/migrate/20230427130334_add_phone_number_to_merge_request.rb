class AddPhoneNumberToMergeRequest < ActiveRecord::Migration[7.0]
  change_table :merge_requests, bulk: true do |t|
    t.column :telephone_number_correct, :boolean
    t.column :new_telephone_number, :string
  end
end
