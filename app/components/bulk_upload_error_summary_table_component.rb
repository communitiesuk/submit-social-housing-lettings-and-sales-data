class BulkUploadErrorSummaryTableComponent < ViewComponent::Base
  attr_reader :bulk_upload

  def initialize(bulk_upload:)
    @bulk_upload = bulk_upload

    super
  end

  def sorted_errors
    @sorted_errors ||= bulk_upload
      .bulk_upload_errors
      .group(:col, :field, :error)
      .count
      .sort_by { |el| el[0][0].rjust(3, "0") }
  end
end
