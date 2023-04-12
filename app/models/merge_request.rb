class MergeRequest < ApplicationRecord
  belongs_to :requesting_organisation, class_name: "Organisation"
end
