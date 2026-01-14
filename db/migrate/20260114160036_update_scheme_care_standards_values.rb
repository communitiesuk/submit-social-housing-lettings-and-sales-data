class UpdateSchemeCareStandardsValues < ActiveRecord::Migration[7.2]
  def change
    Scheme.where(registered_under_care_act: [3, 4]).update!(registered_under_care_act: 5)
  end
end
