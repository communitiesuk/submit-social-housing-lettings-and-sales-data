desc "Forces to recalculate refused values for lettings logs with unknown person details"
task recalculate_refused_values: :environment do
  LettingsLog.exportable.where('details_known_2 = 1
                                OR details_known_3 = 1
                                OR details_known_4 = 1
                                OR details_known_5 = 1
                                OR details_known_6 = 1
                                OR details_known_7 = 1
                                OR details_known_8 = 1').each do |log|
    log.update!(values_updated_at: Time.zone.now)
  end
end
