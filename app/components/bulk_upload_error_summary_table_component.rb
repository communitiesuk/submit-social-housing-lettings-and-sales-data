class BulkUploadErrorSummaryTableComponent < ViewComponent::Base
  DISPLAY_THRESHOLD = 16

  attr_reader :bulk_upload

  delegate :question_for_field, to: :row_parser_class

  def initialize(bulk_upload:)
    @bulk_upload = bulk_upload

    super
  end

  def sorted_errors
    @sorted_errors ||= setup_errors.presence || bulk_upload
      .bulk_upload_errors
      .group(:col, :field, :error)
      .having("count(*) >= ?", display_threshold)
      .order_by_col
      .count
  end

  def errors?
    sorted_errors.present?
  end

  def intro
    if setup_errors.present?
      "This summary shows important questions that have errors. See full error report for more details."
    else
      "This summary shows questions that have more than #{BulkUploadErrorSummaryTableComponent::DISPLAY_THRESHOLD - 1} errors. See full error report for more details."
    end
  end

private

  def setup_errors
    @setup_errors ||= bulk_upload
      .bulk_upload_errors
      .where(category: "setup")
      .group(:col, :field, :error)
      .order_by_col
      .count
  end

  def display_threshold
    DISPLAY_THRESHOLD
  end

  def row_parser_class
    bulk_upload.prefix_namespace::RowParser
  end
end
