class AddValidationsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :validations do |t|
      t.column :log_type, :string
      t.column :section, :string
      t.column :validation_name, :string
      t.column :description, :string
      t.column :case, :string
      t.column :field, :string
      t.column :error_message, :string
      t.column :from, :datetime
      t.column :to, :datetime
      t.column :validation_type, :string
      t.column :hard_soft, :string
      t.column :bulk_upload_specific, :boolean, default: false
      t.column :other_validated_models, :string
      t.timestamps
    end
  end
end
