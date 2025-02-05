desc "Update BU reasonable preference and illness type checkbox values"
task correct_checkbox_values: :environment do
  any_reasonpref_selected = "rp_homeless = 1 OR rp_hardship = 1 OR rp_medwel = 1 OR rp_insan_unsat = 1 OR rp_dontknow = 1"
  any_reasonpref_is_null = "rp_homeless IS NULL OR rp_hardship IS NULL OR rp_medwel IS NULL OR rp_insan_unsat IS NULL OR rp_dontknow IS NULL"

  LettingsLog.filter_by_year(2024).where(reasonpref: 1).where(any_reasonpref_selected).where(any_reasonpref_is_null).find_each do |lettings_log|
    unless lettings_log.save
      Rails.logger.info("Failed to save reasonpref for LettingsLog with id #{lettings_log.id}: #{lettings_log.errors.full_messages}")
    end
  end

  any_illness_selected = "illness_type_1 = 1 OR illness_type_2 = 1 OR illness_type_3 = 1 OR illness_type_4 = 1 OR illness_type_5 = 1 OR illness_type_6 = 1 OR illness_type_7 = 1 OR illness_type_8 = 1 OR illness_type_9 = 1 OR illness_type_10 = 1"
  any_illness_is_null = "illness_type_1 IS NULL OR illness_type_2 IS NULL OR illness_type_3 IS NULL OR illness_type_4 IS NULL OR illness_type_5 IS NULL OR illness_type_6 IS NULL OR illness_type_7 IS NULL OR illness_type_8 IS NULL OR illness_type_9 IS NULL OR illness_type_10 IS NULL"

  LettingsLog.filter_by_year(2024).where(illness: 1).where(any_illness_selected).where(any_illness_is_null).find_each do |lettings_log|
    unless lettings_log.save
      Rails.logger.info("Failed to save illness for LettingsLog with id #{lettings_log.id}: #{lettings_log.errors.full_messages}")
    end
  end
end
