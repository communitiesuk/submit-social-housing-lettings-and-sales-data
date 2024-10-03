module Forms
  module BulkUploadSales
    class Year
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :year, :integer
      attribute :organisation_id, :integer

      validates :year, presence: true

      def view_path
        "bulk_upload_sales_logs/forms/year"
      end

      def options
        possible_years.map do |year|
          OpenStruct.new(id: year, name: "#{year}/#{year + 1}")
        end
      end

      def back_path
        if organisation_id.present?
          sales_logs_organisation_path(organisation_id)
        else
          sales_logs_path
        end
      end

      def next_path
        bulk_upload_sales_log_path(id: "prepare-your-file", form: { year:, organisation_id: }.compact)
      end

      def save!
        true
      end

    private

      def possible_years
        [
          FormHandler.instance.current_sales_form.start_date.year,
          (FormHandler.instance.previous_sales_form.start_date.year if FormHandler.instance.sales_in_crossover_period?),
          (FormHandler.instance.next_sales_form.start_date.year if FeatureToggle.allow_future_form_use?),
        ].compact
      end
    end
  end
end
