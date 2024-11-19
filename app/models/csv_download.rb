class CsvDownload < ApplicationRecord
  enum download_type: { lettings: "lettings", sales: "sales", schemes: "schemes", locations: "locations", combined: "combined" }

  belongs_to :user
  belongs_to :organisation

  def expired?
    created_at < expiration_time.seconds.ago
  end
end
