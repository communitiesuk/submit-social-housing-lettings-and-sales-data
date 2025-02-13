class CollectionResource < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_paper_trail

  attr_accessor :file

  scope :visible, -> { where(discarded_at: nil) }
  validates :short_display_name, presence: true

  def download_path
    if mandatory
      download_mandatory_collection_resource_path(log_type:, year:, resource_type:)
    else
      collection_resource_download_path(self)
    end
  end

  def validate_attached_file
    return errors.add(:file, :blank) unless file
    return errors.add(:file, :above_100_mb) if file.size > 100.megabytes

    argv = %W[file --brief --mime-type -- #{file.path}]
    output = `#{argv.shelljoin}`

    case resource_type
    when "paper_form"
      unless output.match?(/application\/pdf/)
        errors.add(:file, :must_be_pdf)
      end
    when "bulk_upload_template", "bulk_upload_specification"
      unless output.match?(/application\/vnd\.ms-excel|application\/vnd\.openxmlformats-officedocument\.spreadsheetml\.sheet/)
        errors.add(:file, :must_be_xlsx, resource: short_display_name.downcase)
      end
    end
  end

  def validate_short_display_name
    errors.add(:short_display_name, :blank) if short_display_name.blank?
  end

  def discard!
    CollectionResourcesService.new.delete_collection_resource(download_filename)
    update!(discarded_at: Time.zone.now)
  end
end
