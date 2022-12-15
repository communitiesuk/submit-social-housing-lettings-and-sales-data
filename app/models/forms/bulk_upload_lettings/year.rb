module Forms
  module BulkUploadLettings
    class Year
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer

      validates :year, presence: true

      def view_path
        "bulk_upload_lettings_logs/forms/year"
      end

      def options
        possible_years.map do |year|
          OpenStruct.new(id: year, name: "#{year}/#{year + 1}")
        end
      end

      def back_path
        lettings_logs_path
      end

      def next_path
        bulk_upload_lettings_log_path(id: "prepare-your-file", form: { year: })
      end

      def save!
        true
      end

    private

      def possible_years
        FormHandler.instance.lettings_forms.values.map { |form| form.start_date.year }.sort.reverse
      end
    end
  end
end
