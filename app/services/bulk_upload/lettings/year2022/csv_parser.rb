require "csv"

class BulkUpload::Lettings::Year2022::CsvParser
  FIELDS = 134
  MAX_COLUMNS = 135

  attr_reader :path

  def initialize(path:)
    @path = path
  end

  def row_offset
    with_headers? ? 5 : 0
  end

  def col_offset
    with_headers? ? 1 : 0
  end

  def cols
    @cols ||= ("A".."EE").to_a
  end

  def row_parsers
    @row_parsers ||= body_rows.map do |row|
      stripped_row = row[col_offset..]
      hash = Hash[headers.zip(stripped_row)]

      BulkUpload::Lettings::Year2022::RowParser.new(hash)
    end
  end

  def body_rows
    rows[row_offset..]
  end

  def rows
    @rows ||= CSV.parse(normalised_string, row_sep:)
  end

  def column_for_field(field)
    cols[headers.find_index(field) + col_offset]
  end

  def valid_field_numbers_count
    FIELDS
  end

  def with_headers?
    rows[0][0]&.match?(/\D+/)
  end

  private

  def headers
    @headers ||= ("field_1".."field_#{FIELDS}").to_a
  end

  def row_sep
    "\n"
  end

  def normalised_string
    return @normalised_string if @normalised_string

    @normalised_string = File.read(path, encoding: "bom|utf-8")
    @normalised_string.gsub!("\r\n", "\n")
    @normalised_string.scrub!("")

    @normalised_string
  end
end
