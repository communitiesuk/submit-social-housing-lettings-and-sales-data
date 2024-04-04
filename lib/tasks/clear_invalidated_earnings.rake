desc "Clear earnings for lettings logs that fail validation"
task clear_invalidated_earnings: :environment do
  LettingsLog.filter_by_year(2023).find_each do |lettings_log|
    lettings_log.validate_net_income(lettings_log)
    if lettings_log.errors[:earnings].present?
      Rails.logger.info "Clearing earnings for lettings log #{lettings_log.id}, owning_organisation_id: #{lettings_log.owning_organisation_id}, managing_organisation_id: #{lettings_log.managing_organisation_id}, startdate: #{lettings_log.startdate.to_date}, tenancy reference: #{lettings_log.tenancycode}, property reference: #{lettings_log.propcode}, assigned_to: #{lettings_log.assigned_to.email}(#{lettings_log.assigned_to_id}), earnings: #{lettings_log.earnings}, incfreq: #{lettings_log.incfreq}"
      lettings_log.earnings = nil
      lettings_log.incfreq = nil
      lettings_log.save!(validate: false)
    end
  end
end
