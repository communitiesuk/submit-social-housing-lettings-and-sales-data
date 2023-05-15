module Forms
  module BulkUploadLettingsSoftValidationsCheck
    class SoftErrorsValid
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload
      attribute :soft_errors_valid, :string

      validates :soft_errors_valid, presence: true

      def options
        [
          OpenStruct.new(id: "yes", name: "Yes, some of these are errors"),
          OpenStruct.new(id: "no", name: "No, all the data is correct"),
        ]
      end

      def view_path
        "bulk_upload_lettings_soft_validations_check/soft_errors_valid"
      end

      def next_path
        case soft_errors_valid
        when "yes"
          page_bulk_upload_lettings_resume_path(bulk_upload, page: "fix-choice")
        when "no"
          page_bulk_upload_lettings_soft_validations_check_path(bulk_upload, page: "confirm")
        else
          raise "invalid choice"
        end
      end

      def save!
        true
      end
    end
  end
end
