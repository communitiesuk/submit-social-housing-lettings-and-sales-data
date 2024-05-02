desc "Create OrganisationRentPeriods for organisations that have none as they were previously assumed to have all"
task create_organisation_rent_periods: :environment do
  org_ids_with_no_associated_rent_periods = Organisation.includes(:organisation_rent_periods).group(:id).count(:organisation_rent_periods).select { |_org_id, period_count| period_count.zero? }.keys
  org_ids_with_no_associated_rent_periods.each do |organisation_id|
    OrganisationRentPeriod.transaction do
      (1..11).each do |rent_period|
        OrganisationRentPeriod.create(organisation_id:, rent_period:)
      end
    end
  end
end
