ActiveAdmin.register IncomeRange do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params :economic_status, :soft_min, :soft_max, :hard_min, :hard_max
end
