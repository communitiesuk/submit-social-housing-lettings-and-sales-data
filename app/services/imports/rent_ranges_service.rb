module Imports
  class RentRangesService
    attr_reader :start_year, :path, :count

    def initialize(start_year:, path:)
      @start_year = start_year
      @path = path
      @count = 0
    end

    def call
      CSV.foreach(path, headers: true) do |row|
        LaRentRange.upsert(
          { ranges_rent_id: row["ranges_rent_id"],
            lettype: row["lettype"],
            beds: row["beds"],
            start_year:,
            la: row["la"],
            soft_min: row["soft_min"],
            soft_max: row["soft_max"],
            hard_min: row["hard_min"],
            hard_max: row["hard_max"] },
          unique_by: %i[start_year lettype beds la],
        )
        self.count = count + 1
      end
    end

  private

    attr_writer :count
  end
end
