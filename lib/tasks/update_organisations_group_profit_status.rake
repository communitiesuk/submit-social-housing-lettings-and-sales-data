namespace :data_update do
  desc "Update organisations with data from a CSV file"
  task :update_organisations, [:csv_path] => :environment do |_task, args|
    require "csv"

    csv_path = args[:csv_path]
    unless csv_path
      Rails.logger.error "Please provide the path to the CSV file. Example: rake data_update:update_organisations[csv_path]"
      exit
    end

    CSV.foreach(csv_path, headers: true) do |row|
      organisation = Organisation.find_by(id: row["id"].to_i)
      if organisation
        organisation.update!(
          profit_status: map_profit_status(row["profit_status"]),
        )
        # not all orgs have a group
        if row["group"].present?
          organisation.update!(
            group_member: true,
            group: row["group"].to_i,
            # normally set to the ID of the other organisation you picked on the group form
            # we can't set that here so we default to its own org ID
            group_member_id: organisation.id,
          )
        end

        Rails.logger.info "Updated ORG#{row['id']}"
      else
        Rails.logger.warn "Organisation with ID #{row['id']} not found"
      end
    end

    Rails.logger.info "Organisation update task completed"
  end
end

def map_profit_status(profit_status)
  return :non_profit if profit_status == "Non-profit"
  return :profit if profit_status == "Profit"
  return :local_authority if profit_status == "Local authority"

  nil
end
