namespace :data_cleanup do
  desc "Remove all the deactivations for given model with deactivation date after 2031/01/01"
  task :remove_placeholder_deactivations, %i[model_name] => :environment do |_task, args|
    model_name = args[:model_name]
    raise "Usage: rake data_cleanup:remove_placeholder_deactivations['model_name']" if model_name.blank?

    case model_name
    when "location"
      location_deactivation_periods = LocationDeactivationPeriod.where("deactivation_date >= ?", Time.zone.local(2031, 1, 1))
      location_deactivation_periods_count = location_deactivation_periods.count
      location_deactivation_periods.delete_all
      Rails.logger.info("Removed #{location_deactivation_periods_count} location deactivation periods")
    when "scheme"
      scheme_deactivation_periods = SchemeDeactivationPeriod.where("deactivation_date >= ?", Time.zone.local(2031, 1, 1))
      scheme_deactivation_periods_count = scheme_deactivation_periods.count
      scheme_deactivation_periods.delete_all
      Rails.logger.info("Removed #{scheme_deactivation_periods_count} scheme deactivation periods")
    else
      raise "Deactivations for #{model_name} cannot be deleted"
    end
  end
end
