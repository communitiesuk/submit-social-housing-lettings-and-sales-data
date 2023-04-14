class BulkUploadError < ApplicationRecord
  belongs_to :bulk_upload

  scope :order_by_cell, -> { order(Arel.sql("LPAD(cell, 10, '0')")) }
  scope :order_by_col, -> { order(Arel.sql("LPAD(col, 10, '0')")) }
end
