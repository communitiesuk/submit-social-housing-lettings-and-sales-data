class Log < ApplicationRecord
  self.abstract_class = true

  belongs_to :owning_organisation, class_name: "Organisation", optional: true
  belongs_to :managing_organisation, class_name: "Organisation", optional: true
  belongs_to :created_by, class_name: "User", optional: true
end
