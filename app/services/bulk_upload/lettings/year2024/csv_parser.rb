require "csv"

class BulkUpload::Lettings::Year2024::CsvParser
  include CollectionTimeHelper

  FIELDS = 130
  MAX_COLUMNS = 131
  FORM_YEAR = 2024

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
    @cols ||= ("A".."EA").to_a
  end

  def row_parsers
    @row_parsers ||= body_rows.map { |row|
      next if row.empty?

      stripped_row = row[col_offset..]

      hash = Hash[field_numbers.zip(stripped_row)]

      BulkUpload::Lettings::Year2024::RowParser.new(hash)
    }.compact
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
    !with_headers?
  end

private

  def default_field_numbers
    (1..FIELDS).map { |h| h.present? && h.to_s.match?(/^[0-9]+$/) ? "field_#{h}" : "field_blank" }
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
      year = row_parsers.first.field_10.to_s.strip.length.between?(1, 2) ? row_parsers.first.field_10.to_i + 2000 : row_parsers.first.field_10.to_i
      Date.new(year, row_parsers.first.field_9.to_i, row_parsers.first.field_8.to_i)
    else
      year = rows.first[9].to_s.strip.length.between?(1, 2) ? rows.first[9].to_i + 2000 : rows.first[9].to_i
      Date.new(year, rows.first[8].to_i, rows.first[7].to_i)
    end
  end
end
