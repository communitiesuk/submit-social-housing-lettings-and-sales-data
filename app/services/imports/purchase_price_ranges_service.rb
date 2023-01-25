require "csv"

module Imports
  class PurchasePriceRangesService
    attr_reader :start_year, :path, :count

    def initialize(start_year:, path:)
      @start_year = start_year
      @path = path
      @count = 0
    end

    def call
      CSV.foreach(path, headers: true) do |row|
        LaPurchasePriceRange.upsert(
          { start_year:,
            la: row["la"],
            bedrooms: row["bedrooms"],
            soft_min: row["soft_min"],
            soft_max: row["soft_max"] },
          unique_by: %i[start_year bedrooms la],
        )
        self.count = count + 1
      end
    end

  private

    attr_writer :count
  end
end
