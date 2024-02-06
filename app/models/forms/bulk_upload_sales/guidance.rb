module Forms
  module BulkUploadSales
    class Guidance
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer

      def view_path
        "bulk_upload_shared/guidance"
      end

      def back_path
        bulk_upload_sales_log_path(id: "prepare-your-file", form: { year: })
      end

      def lettings_legacy_template_path
        Forms::BulkUploadLettings::PrepareYourFile.new.legacy_template_path
      end

      def lettings_template_path
        Forms::BulkUploadLettings::PrepareYourFile.new(year:).template_path
      end

      def lettings_specification_path
        Forms::BulkUploadLettings::PrepareYourFile.new(year:).specification_path
      end

      def sales_legacy_template_path
        Forms::BulkUploadSales::PrepareYourFile.new.legacy_template_path
      end

      def sales_template_path
        Forms::BulkUploadSales::PrepareYourFile.new(year:).template_path
      end

      def sales_specification_path
        Forms::BulkUploadSales::PrepareYourFile.new(year:).specification_path
      end

      def download_text(lettings_or_sales, file, new_or_legacy = nil)
        "Download the #{lettings_or_sales} bulk upload #{file} (#{year_combo_full})#{new_or_legacy_text(new_or_legacy) if (year == 2023) && new_or_legacy.present?}"
      end

      def year_combo
        "#{year}/#{year - 2000 + 1}"
      end

      def year_combo_full
        "#{year} to #{year + 1}"
      end

      def new_or_legacy_text(new_or_legacy)
        case new_or_legacy
        when "new" then " – New question ordering"
        when "legacy" then " – Legacy version"
        end
      end
    end
  end
end
