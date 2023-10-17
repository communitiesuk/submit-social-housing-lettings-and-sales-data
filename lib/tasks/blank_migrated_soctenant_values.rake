desc "Alter soctenant values for sales logs in the database if the subsequent questions are blank or inferred as don't know"
task blank_migrated_soctenant_values: :environment do
  SalesLog.imported.filter_by_year(2023).where(frombeds: nil, fromprop: 0, socprevten: 10, soctenant: 0).update_all(soctenant: nil, fromprop: nil, socprevten: nil, values_updated_at: Time.zone.now)
end
