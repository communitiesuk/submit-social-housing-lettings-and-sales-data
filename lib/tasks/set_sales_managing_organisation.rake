desc "Set sales managing organisation id to owning organisation id"
task set_sales_managing_organisation: :environment do
  SalesLog.where.not(owning_organisation_id: nil).update_all("managing_organisation_id = owning_organisation_id")
end
