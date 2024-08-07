require "csv"

module Imports
  class SaleRangesService
    attr_reader :start_year, :path, :count

    def initialize(start_year:, path:)
      @start_year = start_year
      @path = path
      @count = 0
    end

    def call
      CSV.foreach(path, headers: true) do |row|
        LaSaleRange.upsert(
          { start_year:,
            la: row["la"],
            bedrooms: row["bedrooms"],
            soft_min: row["soft_min"],
            soft_max: row["soft_max"] },
          unique_by: %i[start_year bedrooms la],
        )
        @count += 1
      end
    end
  end
end
