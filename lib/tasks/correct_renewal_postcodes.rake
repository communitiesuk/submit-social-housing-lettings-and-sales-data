desc "Update lettings logs renewal previous postcode and la data to be the same as current postcode/la"
task correct_renewal_postcodes: :environment do
  LettingsLog.filter_by_year(2023).where(renewal: 1).where("
    ((ppostcode_full != postcode_full)
    OR (ppostcode_full IS NULL AND postcode_full IS NOT NULL)
    OR (postcode_full IS NULL AND ppostcode_full IS NOT NULL))
    OR ((prevloc != la)
    OR (la IS NULL AND prevloc IS NOT NULL)
    OR (prevloc IS NULL AND la IS NOT NULL))
    ").each do |log|
    log.ppostcode_full = log.postcode_full
    log.ppcodenk = case log.postcode_known
                   when 0
                     1
                   when 1
                     0
                   end
    log.is_previous_la_inferred = log.is_la_inferred
    log.previous_la_known = 1 if log.la.present?
    log.prevloc = log.la
    log.values_updated_at = Time.zone.now
    log.save!
  end
end
