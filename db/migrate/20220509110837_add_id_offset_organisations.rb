class AddIdOffsetOrganisations < ActiveRecord::Migration[7.0]
  def up
    execute "SELECT setval('organisations_id_seq', 100000000)"
  end

  def down; end
end
