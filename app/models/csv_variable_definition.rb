class CsvVariableDefinition < ApplicationRecord
  validates :variable, presence: true
  validates :definition, presence: true
  validates :log_type, presence: true, inclusion: { in: %w[lettings sales] }
  validates :user_type, presence: true, inclusion: { in: %w[user support] }
  validates :year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 2000, less_than_or_equal_to: 2099 }
  attribute :last_accessed, :datetime

  scope :user, -> { where(user_type: "user") }
  scope :lettings, -> { where(log_type: "lettings") }
  scope :sales, -> { where(log_type: "sales") }
end
