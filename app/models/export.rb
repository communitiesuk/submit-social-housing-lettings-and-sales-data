class Export < ApplicationRecord
  scope :lettings, -> { where(collection: "lettings") }
  scope :organisations, -> { where(collection: "organisations") }
  scope :users, -> { where(collection: "users") }
end
