module Forms
  module BulkUploadSalesResume
    class FixChoice
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :bulk_upload
      attribute :choice, :string

      validates :choice, presence: true,
                         inclusion: { in: %w[create-fix-inline upload-again] }

      def options
        [
          OpenStruct.new(id: "create-fix-inline", name: "Upload these logs and fix errors on CORE site"),
          OpenStruct.new(id: "upload-again", name: "Fix errors in the CSV and upload the file again"),
        ]
      end

      def view_path
        "bulk_upload_sales_resume/fix_choice"
      end

      def next_path
        case choice
        when "create-fix-inline"
          page_bulk_upload_sales_resume_path(bulk_upload, page: "confirm")
        when "upload-again"
          error_report_path
        else
          raise "invalid choice"
        end
      end

      def error_report_path
        if BulkUploadErrorSummaryTableComponent.new(bulk_upload:).errors?
          summary_bulk_upload_sales_result_path(bulk_upload)
        else
          bulk_upload_sales_result_path(bulk_upload)
        end
      end

      def recommendation
        if BulkUploadErrorSummaryTableComponent.new(bulk_upload:).errors?
          "We recommend fixing these errors in the CSV, as you may be able to edit multiple fields at once. However, you can also upload these logs and fix the errors on the CORE site."
        else
          "We recommend uploading logs and fixing errors on site as you can easily see the questions and select the appropriate answer. However, you can also fix these errors in the CSV."
        end
      end

      def save!
        bulk_upload.update!(choice:) if choice == "upload-again"

        true
      end

      def preflight_valid?
        bulk_upload.choice.blank?
      end

      def preflight_redirect
        case bulk_upload.choice
        when "create-fix-inline"
          page_bulk_upload_sales_resume_path(bulk_upload, :chosen)
        when "bulk-confirm-soft-validations"
          page_bulk_upload_sales_soft_validations_check_path(bulk_upload, :chosen)
        else
          bulk_upload_sales_result_path(bulk_upload)
        end
      end
    end
  end
end
