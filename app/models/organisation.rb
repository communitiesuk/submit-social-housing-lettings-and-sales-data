class Organisation < ApplicationRecord
  has_many :users
  has_many :case_logs, as: :owning_organisation
  has_many :case_logs, as: :managing_organisation
end
