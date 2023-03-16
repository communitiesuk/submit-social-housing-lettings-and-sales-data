class BulkUpload::Sales::Validator
  include ActiveModel::Validations

  attr_reader :bulk_upload, :path

  validate :validate_file_not_empty
  validate :validate_max_columns

  def initialize(bulk_upload:, path:)
    @bulk_upload = bulk_upload
    @path = path
  end

  def call
    row_parsers.each_with_index do |row_parser, index|
      row_parser.valid?

      row = index + row_offset + 1

      row_parser.errors.each do |error|
        bulk_upload.bulk_upload_errors.create!(
          field: error.attribute,
          error: error.type,
          purchaser_code: row_parser.field_1,
          row:,
          cell: "#{cols[field_number_for_attribute(error.attribute) + col_offset - 1]}#{row}",
        )
      end
    end
  end

private

  def field_number_for_attribute(attribute)
    attribute.to_s.split("_").last.to_i
  end

  def rows
    @rows ||= CSV.read(path, row_sep:)
  end

  def body_rows
    rows[row_offset..]
  end

  def row_offset
    5
  end

  def col_offset
    1
  end

  def cols
    @cols ||= ("A".."DV").to_a
  end

  def row_parsers
    @row_parsers ||= body_rows.map do |row|
      stripped_row = row[col_offset..]
      headers = ("field_1".."field_125").to_a
      hash = Hash[headers.zip(stripped_row)]

      BulkUpload::Sales::Year2022::RowParser.new(hash)
    end
  end

  def row_sep
    "\r\n"
    # "\n"
  end

  def validate_file_not_empty
    if File.size(path).zero?
      errors.add(:file, :blank)

      halt_validations!
    end
  end

  def validate_max_columns
    return if halt_validations?

    max_row_size = rows.map(&:size).max

    errors.add(:file, :max_row_size) if max_row_size > 126
  end

  def halt_validations!
    @halt_validations = true
  end

  def halt_validations?
    @halt_validations ||= false
  end
end
