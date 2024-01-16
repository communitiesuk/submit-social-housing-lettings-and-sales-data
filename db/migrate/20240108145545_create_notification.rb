class CreateNotification < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.string :title
      t.string :link_text
      t.string :page_content
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :show_on_unauthenticated_pages

      t.timestamps
    end
  end
end
