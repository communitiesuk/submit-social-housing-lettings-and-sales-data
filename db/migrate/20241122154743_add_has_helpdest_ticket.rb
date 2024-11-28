class AddHasHelpdestTicket < ActiveRecord::Migration[7.0]
  def change
    add_column :merge_requests, :has_helpdesk_ticket, :boolean
  end
end
