require "csv"

class BulkUpload::Sales::Year2023::CsvParser
  include CollectionTimeHelper

  MAX_COLUMNS = 142
  FIELDS = 135
  FORM_YEAR = 2023

  attr_reader :path

  def initialize(path:)
    @path = path
  end

  def row_offset
    if with_headers?
      rows.find_index { |row| row[0].match(/field number/i) } + 1
    else
      0
    end
  end

  def col_offset
    with_headers? ? 1 : 0
  end

  def cols
    @cols ||= ("A".."EK").to_a
  end

  def row_parsers
    @row_parsers ||= body_rows.map do |row|
      stripped_row = row[col_offset..]
      hash = Hash[field_numbers.zip(stripped_row)]

      BulkUpload::Sales::Year2023::RowParser.new(hash)
    end
  end

  def body_rows
    rows[row_offset..]
  end

  def rows
    @rows ||= CSV.parse(normalised_string, row_sep:)
  end

  def column_for_field(field)
    cols[field_numbers.find_index(field) + col_offset]
  end

  def wrong_template_for_year?
    collection_start_year_for_date(first_record_start_date) != FORM_YEAR
  rescue Date::Error
    false
  end

  def missing_required_headers?
    false
  end

  def correct_field_count?
    valid_field_numbers_count = field_numbers.count { |f| f != "field_blank" }

    valid_field_numbers_count == FIELDS
  end

private

  def default_field_numbers
    [6, 3, 4, 5, nil, 28, 30, 38, 47, 51, 55, 59, 31, 39, 48, 52, 56, 60, 37, 46, 50, 54, 58, 35, 43, 49, 53, 57, 61, 32, 33, 78, 80, 79, 81, 83, 84, nil, 62, 66, 64, 65, 63, 67, 69, 70, 68, 76, 77, 16, 17, 18, 26, 24, 25, 27, 8, 91, 95, 96, 97, 92, 93, 94, 98, 100, 101, 103, 104, 106, 110, 111, 112, 113, 114, 9, 116, 117, 118, 120, 124, 125, 126, 10, 11, nil, 127, 129, 133, 134, 135, 1, 2, nil, 73, nil, 75, 107, 108, 121, 122, 130, 131, 82, 109, 123, 132, 115, 15, 86, 87, 29, 7, 12, 13, 14, 36, 44, 45, 88, 89, 102, 105, 119, 128, 19, 20, 21, 22, 23, 34, 40, 41, 42, 71, 72, 74, 85, 90, 99].map do |number|
      if number.to_s.match?(/^[0-9]+$/)
        "field_#{number}"
      else
        "field_blank"
      end
    end
  end

  def field_numbers
    @field_numbers ||= if with_headers?
                         rows[row_offset - 1][col_offset..].map { |number| number.to_s.match?(/^[0-9]+$/) ? "field_#{number}" : "field_blank" }
                       else
                         default_field_numbers
                       end
  end

  def headers
    @headers ||= ("field_1".."field_135").to_a
  end

  def with_headers?
    rows.map { |r| r[0] }.any? { |cell| cell&.match?(/field number/i) }
  end

  def row_sep
    "\n"
  end

  def normalised_string
    return @normalised_string if @normalised_string

    @normalised_string = File.read(path, encoding: "bom|utf-8")
    @normalised_string.gsub!("\r\n", "\n")
    @normalised_string.scrub!("")
    @normalised_string.tr!("\r", "\n")

    @normalised_string
  end

  def first_record_start_date
    if with_headers?
      year = row_parsers.first.field_5.to_s.strip.length.between?(1, 2) ? row_parsers.first.field_5.to_i + 2000 : row_parsers.first.field_5.to_i
      Date.new(year, row_parsers.first.field_4.to_i, row_parsers.first.field_3.to_i)
    else
      year = rows.first[3].to_s.strip.length.between?(1, 2) ? rows.first[3].to_i + 2000 : rows.first[3].to_i
      Date.new(year, rows.first[2].to_i, rows.first[1].to_i)
    end
  end
end
