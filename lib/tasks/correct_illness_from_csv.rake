namespace :correct_illness do
  desc "Export data CSVs for import into Central Data System (CDS)"
  task :create_illness_csv, %i[organisation_id] => :environment do |_task, args|
    organisation_id = args[:organisation_id]
    raise "Usage: rake correct_illness:create_illness_csv['organisation_id']" if organisation_id.blank?

    organisation = Organisation.find_by(id: organisation_id)
    if organisation.present?
      CreateIllnessCsvJob.perform_later(organisation)
      Rails.logger.info("Creating illness CSV for #{organisation.name}")
    else
      Rails.logger.error("Organisation with ID #{organisation_id} not found")
    end
  end
end
