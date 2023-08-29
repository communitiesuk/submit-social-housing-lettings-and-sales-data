desc "Update has_other_client_group values for schemes"
task correct_has_other_client_group_values: :environment do
  Scheme.where(confirmed: true, secondary_client_group: nil).update_all(has_other_client_group: 0)
  Scheme.where(confirmed: true).where.not(secondary_client_group: nil).update_all(has_other_client_group: 1)
end
