desc "Update schemes that had a level of support of 'Nursing' to be incomplete, and mark all logs that use that scheme as incomplete"
task update_schemes_logs_impacted_by_nursing_level_removal: :environment do
  ActiveRecord::Base.transaction do
    impacted_schemes = Scheme.where(support_type: 5)
    impacted_logs = LettingsLog.filter_by_year_or_later(2025).where(scheme: impacted_schemes)

    impacted_schemes.update!(support_type: nil, confirmed: false)
    impacted_logs.update!(scheme: nil)
  end
end
