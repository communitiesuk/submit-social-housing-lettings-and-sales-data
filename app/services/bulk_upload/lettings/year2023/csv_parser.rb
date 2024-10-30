require "csv"

class BulkUpload::Lettings::Year2023::CsvParser
  include CollectionTimeHelper

  FIELDS = 134
  MAX_COLUMNS = 142
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
    @cols ||= ("A".."EL").to_a
  end

  def row_parsers
    @row_parsers ||= body_rows.map do |row|
      stripped_row = row[col_offset..]
      hash = Hash[field_numbers.zip(stripped_row)]

      BulkUpload::Lettings::Year2023::RowParser.new(hash)
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

  def correct_field_count?
    valid_field_numbers_count = field_numbers.count { |f| f != "field_blank" }

    valid_field_numbers_count == FIELDS
  end

  def too_many_columns?
    return if with_headers?

    max_columns_count = body_rows.map(&:size).max - col_offset

    max_columns_count > MAX_COLUMNS
  end

  def wrong_template_for_year?
    collection_start_year_for_date(first_record_start_date) != FORM_YEAR
  rescue Date::Error
    false
  end

  def missing_required_headers?
    false
  end

private

  def default_field_numbers
    [5, nil, nil, 15, 16, nil, 13, 40, 41, 42, 43, 46, 52, 56, 60, 64, 68, 72, 76, 47, 53, 57, 61, 65, 69, 73, 77, 51, 55, 59, 63, 67, 71, 75, 50, 54, 58, 62, 66, 70, 74, 78, 48, 49, 79, 81, 82, 123, 124, 122, 120, 102, 103, nil, 83, 84, 85, 86, 87, 88, 104, 109, 107, 108, 106, 100, 101, 105, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 126, 128, 129, 130, 131, 132, 127, 125, 133, 134, 33, 34, 35, 36, 37, 38, nil, 7, 8, 9, 28, 14, 32, 29, 30, 31, 26, 27, 25, 23, 24, nil, 1, 3, 2, 80, nil, 121, 44, 89, 98, 92, 95, 90, 91, 93, 94, 97, 96, 99, 10, 11, 12, 45, 39, 6, 4, 17, 18, 19, 20, 21, 22].map { |h| h.present? && h.to_s.match?(/^[0-9]+$/) ? "field_#{h}" : "field_blank" }
  end

  def field_numbers
    @field_numbers ||= if with_headers?
                         rows[row_offset - 1][col_offset..].map { |h| h.present? && h.match?(/^[0-9]+$/) ? "field_#{h}" : "field_blank" }
                       else
                         default_field_numbers
                       end
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
      year = row_parsers.first.field_9.to_s.strip.length.between?(1, 2) ? row_parsers.first.field_9.to_i + 2000 : row_parsers.first.field_9.to_i
      Date.new(year, row_parsers.first.field_8.to_i, row_parsers.first.field_7.to_i)
    else
      year = rows.first[97].to_s.strip.length.between?(1, 2) ? rows.first[97].to_i + 2000 : rows.first[97].to_i
      Date.new(year, rows.first[96].to_i, rows.first[95].to_i)
    end
  end
end
