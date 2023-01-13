class BulkUpload::Lettings::LogCreator
  attr_reader :bulk_upload, :path

  def initialize(bulk_upload:, path:)
    @bulk_upload = bulk_upload
    @path = path
  end

  def call
    row_parsers.each do |row_parser|
      next unless row_parser.valid?

      row_parser.log.bulk_upload = bulk_upload
      row_parser.log.save
    end
  end

private

  def row_offset
    5
  end

  def col_offset
    1
  end

  def row_parsers
    @row_parsers ||= body_rows.map do |row|
      stripped_row = row[col_offset..]
      headers = ("field_1".."field_134").to_a
      hash = Hash[headers.zip(stripped_row)]
      hash[:bulk_upload] = bulk_upload

      BulkUpload::Lettings::RowParser.new(hash)
    end
  end

  def body_rows
    rows[row_offset..]
  end

  def rows
    @rows ||= CSV.read(path, row_sep:)
  end

  # determine the row seperator from CSV
  # Windows will use \r\n
  def row_sep
    contents = ""

    File.open(path, "r") do |f|
      f.seek(9900)
      contents = f.read
    end

    rn_count = contents.scan("\r\n").count
    n_count = contents.scan(/[^\r]\n/).count

    if rn_count > n_count
      "\r\n"
    else
      "\n"
    end
  end
end
