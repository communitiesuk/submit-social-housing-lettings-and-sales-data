class AddIdOffsetOrganisations < ActiveRecord::Migration[7.0]
  def change
    execute "SELECT setval('organisations_id_seq', 100000000)"
  end
end
