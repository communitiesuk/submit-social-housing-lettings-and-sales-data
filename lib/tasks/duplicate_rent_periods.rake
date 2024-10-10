def process_duplicate_rent_periods(log_groups: true)
  duplicate_groups = OrganisationRentPeriod
                       .select("organisation_id, rent_period")
                       .group("organisation_id, rent_period")
                       .having("COUNT(*) > 1")

  affected_records = OrganisationRentPeriod
                        .where(organisation_id: duplicate_groups.map(&:organisation_id), rent_period: duplicate_groups.map(&:rent_period))

  if log_groups
    duplicate_groups.each do |group|
      group_records = affected_records.where(organisation_id: group.organisation_id, rent_period: group.rent_period)
      group_records.each do |record|
        Rails.logger.info "ID: #{record.id}, Organisation ID: #{record.organisation_id}, Rent Period: #{record.rent_period}"
      end
      Rails.logger.info "----------------------"
    end
  end

  to_keep_ids = OrganisationRentPeriod
                  .select("MIN(id) as id")
                  .group("organisation_id, rent_period")
                  .having("COUNT(*) > 1")
                  .map(&:id)

  duplicate_ids = affected_records.pluck(:id) - to_keep_ids

  {
    affected_records:,
    to_keep_ids:,
    duplicate_ids:,
  }
end

desc "Find and output each group of duplicate rent periods with counts"
task find_redundant_rent_periods: :environment do
  result = process_duplicate_rent_periods(log_groups: true)

  Rails.logger.info "Total number of records: #{OrganisationRentPeriod.count}"
  Rails.logger.info "Number of affected records: #{result[:affected_records].size}"
  Rails.logger.info "Number of affected records to delete: #{result[:duplicate_ids].size}"
  Rails.logger.info "Number of affected records to keep: #{result[:to_keep_ids].size}"
end

desc "Delete duplicate rent periods"
task delete_duplicate_rent_periods: :environment do
  result = process_duplicate_rent_periods(log_groups: false)

  OrganisationRentPeriod.where(id: result[:duplicate_ids]).delete_all

  Rails.logger.info "Number of deleted duplicate records: #{result[:duplicate_ids].size}"
end
