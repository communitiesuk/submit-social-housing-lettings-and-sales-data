class AddValidationsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :validations do |t|
      t.column :log_type, :string
      t.column :validation_name, :string
      t.column :description, :string
      t.column :field, :string
      t.column :error_message, :string
      t.column :case, :string
      t.column :section, :string
      t.column :from, :datetime
      t.column :to, :datetime
      t.column :validation_type, :string
      t.column :hard_soft, :string
      t.timestamps
    end
  end
end
