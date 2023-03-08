require "csv"

module Imports
  class LocalAuthoritiesService
    attr_reader :path, :count

    def initialize(path:)
      @path = path
      @count = 0
    end

    def call
      CSV.foreach(path, headers: true) do |row|
        LocalAuthority.upsert(
          { code: row["code"],
            la_name: row["la_name"],
            start_date: Time.zone.local(row["start_year"], 4, 1),
            end_date: (Time.zone.local(row["end_year"], 3, 31) if row["end_year"]),
            previous_location_only: row["previous_location_only"] || false },
        )
        @count += 1
      end
    end
  end
end
