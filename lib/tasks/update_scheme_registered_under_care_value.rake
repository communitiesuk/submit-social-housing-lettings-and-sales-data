desc "Alter registered under care act values for schemes in the database to 5 if they are 3 or 4, as these options are being deprecated"
task update_scheme_registered_under_care_value: :environment do
  Scheme.where(registered_under_care_act: [3, 4]).update_all(registered_under_care_act: 5)
end
