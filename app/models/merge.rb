class Merge
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :merging_organisations, array: true, default: []
end
