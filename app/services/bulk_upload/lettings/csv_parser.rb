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
      # hash[:bulk_upload] = bulk_upload

      BulkUpload::Lettings::RowParser.new(hash)
    end
  end

  def body_rows
    rows[row_offset..]
  end

  def rows
    @rows ||= CSV.read(path, row_sep:)
  end

private

  # determine the row seperator from CSV
  # Windows will use \r\n
  def row_sep
    contents = ""

    File.open(path, "r") do |f|
      contents = f.read
    end

    if contents[-2..] == "\r\n"
      "\r\n"
    else
      "\n"
    end
  end
end
