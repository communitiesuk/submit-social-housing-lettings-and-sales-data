desc "Forces to recalculate irproduct values"
task recalculate_irproduct_values: :environment do
  LettingsLog.exportable.where(rent_type: [3, 4, 5]).where(irproduct: nil).each do |log| # irproduct was never set
    Rails.logger.info("Could not update irproduct for LettingsLog #{log.id}") unless log.update(values_updated_at: Time.zone.now)
  end
  LettingsLog.exportable.where(rent_type: 3).where.not(irproduct: 1).each do |log| # irproduct was set wrong
    Rails.logger.info("Could not update irproduct for LettingsLog #{log.id}") unless log.update(values_updated_at: Time.zone.now)
  end
  LettingsLog.exportable.where(rent_type: 4).where.not(irproduct: 2).each do |log| # irproduct was set wrong
    Rails.logger.info("Could not update irproduct for LettingsLog #{log.id}") unless log.update(values_updated_at: Time.zone.now)
  end
  LettingsLog.exportable.where(rent_type: 5).where.not(irproduct: 3).each do |log| # irproduct was set wrong
    Rails.logger.info("Could not update irproduct for LettingsLog #{log.id}") unless log.update(values_updated_at: Time.zone.now)
  end
  LettingsLog.exportable.where.not(rent_type: [3, 4, 5]).where.not(irproduct: nil).each do |log| # irproduct was set when it should have been nil
    Rails.logger.info("Could not update irproduct for LettingsLog #{log.id}") unless log.update(values_updated_at: Time.zone.now)
  end
end
