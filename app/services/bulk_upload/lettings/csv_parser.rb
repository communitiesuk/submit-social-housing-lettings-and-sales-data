require "csv"

class BulkUpload::Lettings::CsvParser
  attr_reader :path

  def initialize(path:)
    @path = path
  end

  def row_offset
    5
  end

  def col_offset
    1
  end

  def cols
    @cols ||= ("A".."EE").to_a
  end

  def row_parsers
    @row_parsers ||= body_rows.map do |row|
      stripped_row = row[1..]
      headers = ("field_1".."field_134").to_a
      hash = Hash[headers.zip(stripped_row)]

      BulkUpload::Lettings::RowParser.new(hash)
    end
  end

  def body_rows
    rows[row_offset..]
  end

  def rows
    @rows ||= CSV.parse(normalised_string, row_sep:)
  end

private

  def row_sep
    "\n"
  end

  def normalised_string
    return @normalised_string if @normalised_string

    @normalised_string = File.read(path)
    @normalised_string.gsub!("\r\n", "\n")

    @normalised_string
  end
end
