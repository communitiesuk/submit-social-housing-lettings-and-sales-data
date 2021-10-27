ActiveAdmin.register IncomeRange do
  # See permitted parameters documentation:
  permit_params :economic_status, :soft_min, :soft_max, :hard_min, :hard_max
end
