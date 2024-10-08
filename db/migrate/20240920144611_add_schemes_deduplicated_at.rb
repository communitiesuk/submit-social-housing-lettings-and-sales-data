class AddSchemesDeduplicatedAt < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :schemes_deduplicated_at, :datetime
  end
end
