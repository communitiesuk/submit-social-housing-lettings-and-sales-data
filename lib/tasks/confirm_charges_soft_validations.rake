desc "Confirms scharge, pscharge and supcharge soft validations for completed logs"
task confirm_charges_soft_validations: :environment do
  LettingsLog.where(status: "completed").filter_by_year(2022).each do |log|
    log.update!(scharge_value_check: 0, values_updated_at: Time.zone.now) if log.scharge_value_check.blank? && log.scharge_over_soft_max?
    log.update!(pscharge_value_check: 0, values_updated_at: Time.zone.now) if log.pscharge_value_check.blank? && log.pscharge_over_soft_max?
    log.update!(supcharg_value_check: 0, values_updated_at: Time.zone.now) if log.supcharg_value_check.blank? && log.supcharg_over_soft_max?
  end

  LettingsLog.where(status: "completed").filter_by_year(2023).each do |log|
    log.update!(scharge_value_check: 0, values_updated_at: Time.zone.now) if log.scharge_value_check.blank? && log.scharge_over_soft_max?
    log.update!(pscharge_value_check: 0, values_updated_at: Time.zone.now) if log.pscharge_value_check.blank? && log.pscharge_over_soft_max?
    log.update!(supcharg_value_check: 0, values_updated_at: Time.zone.now) if log.supcharg_value_check.blank? && log.supcharg_over_soft_max?
  end
end
