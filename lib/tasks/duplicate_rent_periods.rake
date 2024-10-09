def process_duplicate_rent_periods(log_groups: true)
  duplicate_groups = OrganisationRentPeriod
                       .select("organisation_id, rent_period")
                       .group("organisation_id, rent_period")
                       .having("COUNT(*) > 1")

  duplicate_records = OrganisationRentPeriod
                        .where(organisation_id: duplicate_groups.map(&:organisation_id), rent_period: duplicate_groups.map(&:rent_period))

  if log_groups
    duplicate_groups.each do |group|
      group_records = duplicate_records.where(organisation_id: group.organisation_id, rent_period: group.rent_period)
      group_records.each do |record|
        Rails.logger.info "ID: #{record.id}, Organisation ID: #{record.organisation_id}, Rent Period: #{record.rent_period}"
      end
      Rails.logger.info "----------------------"
    end
  end

  ids_to_keep = OrganisationRentPeriod
                  .select("MIN(id) as id")
                  .group("organisation_id, rent_period")
                  .having("COUNT(*) > 1")
                  .map(&:id)

  redundant_ids = duplicate_records.pluck(:id) - ids_to_keep

  {
    duplicate_records: duplicate_records,
    ids_to_keep: ids_to_keep,
    redundant_ids: redundant_ids
  }
end

desc "Find and output each group of duplicate rent periods with a total count"
task find_redundant_rent_periods: :environment do
  result = process_duplicate_rent_periods(log_groups: true)

  Rails.logger.info "Total number of records: #{OrganisationRentPeriod.count}"
  Rails.logger.info "Number of duplicate records: #{result[:duplicate_records].size}"
  Rails.logger.info "Number of records to delete: #{result[:redundant_ids].size}"
  Rails.logger.info "Number of records to keep: #{result[:ids_to_keep].size}"
end

desc "Delete redundant rent periods"
task delete_duplicate_rent_periods: :environment do
  result = process_duplicate_rent_periods(log_groups: false)

  OrganisationRentPeriod.where(id: result[:redundant_ids]).delete_all

  Rails.logger.info "Number of deleted duplicate records: #{result[:redundant_ids].size}"
end
