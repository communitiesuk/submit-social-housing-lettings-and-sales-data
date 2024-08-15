require "csv"

module Imports
  class VariableDefinitionsService
    attr_reader :path, :count

    def initialize(path:)
      @path = path
      @count = 0
    end

    def call
      files = Dir.glob(File.join(@path, "*.csv"))
      files.each do |file|
        process_file(file)
      end
    end

  private

    def process_file(file)
      file_name = File.basename(file, ".csv")
      parsed_file_name = file_name.split("_")
      log_type = parsed_file_name[0]
      year = "20#{parsed_file_name[2]}".to_i

      records_added = 0

      CSV.foreach(file) do |row|
        next if row.empty?

        variable = row[0].downcase
        definition = row[1..].join(",")
        next if variable.nil? || definition.nil?

        existing_record = CsvVariableDefinition.find_by(variable: variable.strip, definition: definition.strip, log_type:)

        if existing_record.nil?
          CsvVariableDefinition.create!(
            variable: variable.strip,
            definition: definition.strip,
            log_type:,
            year:,
          )
          records_added += 1
        end
      end

      Rails.logger.debug "Added #{records_added} variable/definition records for file: #{file_name}. Duplicates excluded."
      @count += records_added
    end
  end
end
