require "csv"

module Imports
  class LocalAuthorityLinksService
    attr_reader :path, :count

    def initialize(path:)
      @path = path
      @count = 0
    end

    def call
      CSV.foreach(path, headers: true) do |row|
        LocalAuthorityLink.upsert(
          { local_authority_id: LocalAuthority.find_by(code: row["local_authority_code"]).id,
            linked_local_authority_id: LocalAuthority.find_by(code: row["linked_local_authority_code"]).id },
        )
        @count += 1
      end
    end
  end
end
