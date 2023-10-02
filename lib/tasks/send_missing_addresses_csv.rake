namespace :correct_addresses do
  # rubocop:disable Lint/ConstantDefinitionInBlock
  MISSING_ADDRESSES_THRESHOLD = 50
  # rubocop:enable Lint/ConstantDefinitionInBlock

  desc "Send missing lettings addresses csv"
  task :send_missing_addresses_lettings_csv, %i[] => :environment do |_task, _args|
    Organisation.all.each do |organisation|
      logs_impacted_by_missing_address = organisation.managed_lettings_logs
      .imported
      .filter_by_year(2023)
      .where(needstype: 1, address_line1: nil, town_or_city: nil, uprn_known: [0, nil])
      .where.not(old_form_id: nil).count

      logs_impacted_by_missing_town_or_city = organisation.managed_lettings_logs
      .imported
      .filter_by_year(2023)
      .where(needstype: 1, town_or_city: nil, uprn_known: [0, nil])
      .where.not(old_form_id: nil)
      .where.not(address_line1: nil).count

      logs_impacted_by_uprn_issue = if JSON.parse(ENV["SKIP_UPRN_ISSUE_ORG_IDS"]).include?(organisation.id)
                                      []
                                    else
                                      organisation.managed_lettings_logs
                                      .imported
                                      .filter_by_year(2023)
                                      .where(needstype: 1)
                                      .where.not(uprn: nil)
                                      .where("uprn = propcode OR uprn = tenancycode or town_or_city = 'Bristol'")
                                    end
      if logs_impacted_by_missing_address >= MISSING_ADDRESSES_THRESHOLD || logs_impacted_by_missing_town_or_city >= MISSING_ADDRESSES_THRESHOLD || logs_impacted_by_uprn_issue.any?
        data_coordinators = organisation.users.where(role: 2).filter_by_active
        users_to_contact = data_coordinators.any? ? data_coordinators : organisation.users.filter_by_active
        EmailMissingAddressesCsvJob.perform_later(users_to_contact.map(&:id), organisation, "lettings")
        Rails.logger.info("Sending missing lettings addresses CSV for #{organisation.name} to #{users_to_contact.map(&:email).join(', ')}")
      else
        Rails.logger.info("Missing addresses below threshold for #{organisation.name}")
      end
    end
  end

  desc "Send missing sales addresses csv"
  task :send_missing_addresses_sales_csv, %i[] => :environment do |_task, _args|
    Organisation.all.each do |organisation|
      logs_impacted_by_missing_address = organisation.sales_logs
      .imported
      .filter_by_year(2023)
      .where(address_line1: nil, town_or_city: nil, uprn_known: [0, nil])
      .where.not(old_form_id: nil).count

      logs_impacted_by_missing_town_or_city = organisation.sales_logs
      .imported
      .filter_by_year(2023)
      .where(town_or_city: nil, uprn_known: [0, nil])
      .where.not(old_form_id: nil)
      .where.not(address_line1: nil).count

      logs_impacted_by_uprn_issue = if JSON.parse(ENV["SKIP_UPRN_ISSUE_ORG_IDS"]).include?(organisation.id)
                                      []
                                    else
                                      organisation.sales_logs
                                      .imported
                                      .filter_by_year(2023)
                                      .where.not(uprn: nil)
                                      .where("uprn = purchid or town_or_city = 'Bristol'")
                                    end
      if logs_impacted_by_missing_address >= MISSING_ADDRESSES_THRESHOLD || logs_impacted_by_missing_town_or_city >= MISSING_ADDRESSES_THRESHOLD || logs_impacted_by_uprn_issue.any?
        data_coordinators = organisation.users.where(role: 2).filter_by_active
        users_to_contact = data_coordinators.any? ? data_coordinators : organisation.users.filter_by_active
        EmailMissingAddressesCsvJob.perform_later(users_to_contact.map(&:id), organisation, "sales")
        Rails.logger.info("Sending missing sales addresses CSV for #{organisation.name} to #{users_to_contact.map(&:email).join(', ')}")
      else
        Rails.logger.info("Missing addresses below threshold for #{organisation.name}")
      end
    end
  end
end
