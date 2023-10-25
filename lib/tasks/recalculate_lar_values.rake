desc "Forces to recalculate lar values for affordable rent types and clears irrelevant lar values"
task recalculate_lar_values: :environment do
  LettingsLog.exportable.where(rent_type: [1, 2], lar: nil).each do |log| # lar was never set
    Rails.logger.info("Could not update lar for LettingsLog #{log.id}") unless log.update(values_updated_at: Time.zone.now)
  end
  LettingsLog.exportable.where(rent_type: 1).where.not(lar: 2).each do |log| # lar was set wrong
    Rails.logger.info("Could not update lar for LettingsLog #{log.id}") unless log.update(values_updated_at: Time.zone.now)
  end
  LettingsLog.exportable.where(rent_type: 2).where.not(lar: 1).each do |log| # lar was set wrong
    Rails.logger.info("Could not update lar for LettingsLog #{log.id}") unless log.update(values_updated_at: Time.zone.now)
  end
  LettingsLog.exportable.where.not(rent_type: [1, 2]).where.not(lar: nil).update_all(lar: nil) # lar was set to 2 but should never have been set
end
