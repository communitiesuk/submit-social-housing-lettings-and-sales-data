require "csv"

class BulkUpload::Sales::Year2026::CsvParser
  include CollectionTimeHelper

  FIELDS = 136
  FORM_YEAR = 2026

  attr_reader :path

  ROW_PARSER_CLASS = BulkUpload::Sales::Year2026::RowParser

  def initialize(path:)
    @path = path
  end

  def row_offset
    if with_headers?
      rows.find_index { |row| row[0].present? && row[0].match(/field number/i) } + 1
    else
      0
    end
  end

  def col_offset
    with_headers? ? 1 : 0
  end

  def cols
    @cols ||= ("A".."EG").to_a
  end

  def row_parsers
    @row_parsers ||= body_rows.map { |row|
      next if row.empty?

      invalid_fields = []
      stripped_row = row[col_offset..]

      hash_rows = field_numbers
                    .zip(stripped_row)
                    .map do |field, value|
                      field_is_valid = value_is_valid_for_field(field, value)

                      correct_value = field_is_valid ? value : nil

                      invalid_fields << field unless field_is_valid

                      [field, correct_value]
                    end

      hash = Hash[hash_rows]

      row_parser = ROW_PARSER_CLASS.new(hash)

      invalid_fields.each do |field|
        row_parser.add_invalid_field(field)
      end

      row_parser
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

  def wrong_template_for_year?
    collection_start_year_for_date(first_record_start_date) != FORM_YEAR
  rescue Date::Error
    false
  end

  def missing_required_headers?
    !with_headers?
  end

  def correct_field_count?
    valid_field_numbers_count = field_numbers.count { |f| f != "field_blank" }

    valid_field_numbers_count == FIELDS
  end

private

  def default_field_numbers
    (1..FIELDS).map do |number|
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
    @headers ||= ("field_1".."field_#{FIELDS}").to_a
  end

  def with_headers?
    # we will eventually want to validate that headers exist for this year
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

  # this is needed as a string passed to an int attribute is by default mapped to '0'.
  # this is bad as some questions will accept a '0'. so you could enter something invalid and not be told about it
  def value_is_valid_for_field(field, value)
    field_type = ROW_PARSER_CLASS.attribute_types[field]

    if field_type.is_a?(ActiveModel::Type::Integer)
      value.nil? || Integer(value, exception: false).present?
    elsif field_type.is_a?(ActiveModel::Type::Decimal)
      value.nil? || Float(value, exception: false).present?
    else
      true
    end
  end

  def first_record_start_date
    if with_headers?
      year = row_parsers.first.field_3.to_s.strip.length.between?(1, 2) ? row_parsers.first.field_3.to_i + 2000 : row_parsers.first.field_3.to_i
      Date.new(year, row_parsers.first.field_2.to_i, row_parsers.first.field_1.to_i)
    else
      year = rows.first[2].to_s.strip.length.between?(1, 2) ? rows.first[2].to_i + 2000 : rows.first[2].to_i
      Date.new(year, rows.first[1].to_i, rows.first[0].to_i)
    end
  end
end
