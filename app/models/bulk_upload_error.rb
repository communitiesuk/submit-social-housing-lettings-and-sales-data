class BulkUploadError < ApplicationRecord
  belongs_to :bulk_upload

  scope :order_by_row, -> { order("row::integer ASC") }
  scope :order_by_cell, -> { order(Arel.sql("LPAD(cell, 10, '0')")) }
  scope :order_by_col, -> { order(Arel.sql("LPAD(col, 10, '0')")) }
  scope :important, -> { where(category: "setup") }
  scope :potential, -> { where(category: "soft_validation") }
  scope :not_potential, -> { where.not(category: "soft_validation").or(where(category: nil)) }
  scope :critical, -> { where(category: nil).or(where.not(category: %w[setup soft_validation])) }
  scope :critical_or_important, -> { critical.or(important) }
end
