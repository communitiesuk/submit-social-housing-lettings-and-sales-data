namespace :correct_addresses do
  desc "Send missing lettings addresses csv"
  task :send_missing_addresses_lettings_csv, %i[skip_uprn_issue_organisations] => :environment do |_task, args|
    skip_uprn_issue_organisations = args[:skip_uprn_issue_organisations]&.split(" ")&.map(&:to_i) || []

    Organisation.all.each do |organisation|
      logs_impacted_by_missing_address = organisation.managed_lettings_logs
      .imported_2023_with_old_form_id
      .where(needstype: 1, address_line1: nil, town_or_city: nil, uprn_known: [0, nil]).count

      logs_impacted_by_missing_town_or_city = organisation.managed_lettings_logs
      .imported_2023_with_old_form_id
      .where(needstype: 1, town_or_city: nil, uprn_known: [0, nil])
      .where.not(address_line1: nil).count

      logs_impacted_by_uprn_issue = if skip_uprn_issue_organisations.include?(organisation.id)
                                      []
                                    else
                                      organisation.managed_lettings_logs
                                      .imported_2023
                                      .where(needstype: 1)
                                      .where.not(uprn: nil)
                                      .where("uprn = propcode OR uprn = tenancycode")
                                    end

      logs_impacted_by_bristol_uprn_issue = if skip_uprn_issue_organisations.include?(organisation.id)
                                              []
                                            else
                                              organisation.managed_lettings_logs
                                              .imported_2023
                                              .where(needstype: 1)
                                              .where.not(uprn: nil)
                                              .where("town_or_city = 'Bristol'")
                                            end

      missing_addresses_threshold = EmailMissingAddressesCsvJob::MISSING_ADDRESSES_THRESHOLD
      if logs_impacted_by_missing_address >= missing_addresses_threshold || logs_impacted_by_missing_town_or_city >= missing_addresses_threshold || logs_impacted_by_uprn_issue.any? || logs_impacted_by_bristol_uprn_issue.any?
        issue_types = []
        issue_types << "missing_address" if logs_impacted_by_missing_address.positive?
        issue_types << "missing_town" if logs_impacted_by_missing_town_or_city.positive?
        issue_types << "wrong_uprn" if logs_impacted_by_uprn_issue.any?
        issue_types << "bristol_uprn" if logs_impacted_by_bristol_uprn_issue.any?
        data_coordinators = organisation.users.where(role: 2).filter_by_active
        users_to_contact = data_coordinators.any? ? data_coordinators : organisation.users.filter_by_active
        EmailMissingAddressesCsvJob.perform_later(users_to_contact.map(&:id), organisation, "lettings", issue_types, skip_uprn_issue_organisations)
        Rails.logger.info("Sending missing lettings addresses CSV for #{organisation.name} to #{users_to_contact.map(&:email).join(', ')}")
      else
        Rails.logger.info("Missing addresses below threshold for #{organisation.name}")
      end
    end
  end

  desc "Send missing sales addresses csv"
  task :send_missing_addresses_sales_csv, %i[skip_uprn_issue_organisations] => :environment do |_task, args|
    skip_uprn_issue_organisations = args[:skip_uprn_issue_organisations]&.split(" ")&.map(&:to_i) || []

    Organisation.all.each do |organisation|
      logs_impacted_by_missing_address = organisation.sales_logs
      .imported_2023_with_old_form_id
      .where(address_line1: nil, town_or_city: nil, uprn_known: [0, nil]).count

      logs_impacted_by_missing_town_or_city = organisation.sales_logs
      .imported_2023_with_old_form_id
      .where(town_or_city: nil, uprn_known: [0, nil])
      .where.not(address_line1: nil).count

      logs_impacted_by_uprn_issue = if skip_uprn_issue_organisations.include?(organisation.id)
                                      []
                                    else
                                      organisation.sales_logs
                                      .imported_2023
                                      .where.not(uprn: nil)
                                      .where("uprn = purchid OR town_or_city = 'Bristol'")
                                    end
      missing_addresses_threshold = EmailMissingAddressesCsvJob::MISSING_ADDRESSES_THRESHOLD
      if logs_impacted_by_missing_address >= missing_addresses_threshold || logs_impacted_by_missing_town_or_city >= missing_addresses_threshold || logs_impacted_by_uprn_issue.any?
        issue_types = []
        issue_types << "missing_address" if logs_impacted_by_missing_address.positive?
        issue_types << "missing_town" if logs_impacted_by_missing_town_or_city.positive?
        issue_types << "wrong_uprn" if logs_impacted_by_uprn_issue.any?
        data_coordinators = organisation.users.where(role: 2).filter_by_active
        users_to_contact = data_coordinators.any? ? data_coordinators : organisation.users.filter_by_active
        EmailMissingAddressesCsvJob.perform_later(users_to_contact.map(&:id), organisation, "sales", issue_types, skip_uprn_issue_organisations)
        Rails.logger.info("Sending missing sales addresses CSV for #{organisation.name} to #{users_to_contact.map(&:email).join(', ')}")
      else
        Rails.logger.info("Missing addresses below threshold for #{organisation.name}")
      end
    end
  end

  desc "Send all 2023 lettings addresses csv"
  task :create_lettings_addresses_csv, %i[organisation_id] => :environment do |_task, args|
    organisation_id = args[:organisation_id]
    raise "Usage: rake correct_addresses:create_lettings_addresses_csv['organisation_id']" if organisation_id.blank?

    organisation = Organisation.find_by(id: organisation_id)
    if organisation.present?
      CreateAddressesCsvJob.perform_later(organisation, "lettings")
      Rails.logger.info("Creating lettings addresses CSV for #{organisation.name}")
    else
      Rails.logger.error("Organisation with ID #{organisation_id} not found")
    end
  end

  desc "Send all 2023 sales addresses csv"
  task :create_sales_addresses_csv, %i[organisation_id] => :environment do |_task, args|
    organisation_id = args[:organisation_id]
    raise "Usage: rake correct_addresses:create_sales_addresses_csv['organisation_id']" if organisation_id.blank?

    organisation = Organisation.find_by(id: organisation_id)
    if organisation.present?
      CreateAddressesCsvJob.perform_later(organisation, "sales")
      Rails.logger.info("Creating sales addresses CSV for #{organisation.name}")
    else
      Rails.logger.error("Organisation with ID #{organisation_id} not found")
    end
  end
end
