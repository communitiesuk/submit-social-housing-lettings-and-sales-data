class CreateLogsView < ActiveRecord::Migration[7.0]
  def change
    create_view :logs
  end
end
