class AddIdOffsetOrganisationsAndLogs < ActiveRecord::Migration[7.0]
  def up
    execute "SELECT setval('organisations_id_seq', 100000000)"
    execute "SELECT setval('case_logs_id_seq', 300000000000)"
  end

  def down; end
end
