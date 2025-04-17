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
        organisation.skip_group_member_validation = true
        organisation.update!(
          profit_status: row["profit_status"].to_i,
          group_member: true,
          group: row["group"].to_i,
        )
        Rails.logger.info "Updated ORG#{row['id']}"
      else
        Rails.logger.warn "Organisation with ID #{row['id']} not found"
      end
    end

    Rails.logger.info "Organisation update task completed"
  end
end
