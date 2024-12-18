module Forms
  module BulkUploadForm
    class Year
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Rails.application.routes.url_helpers

      attribute :log_type
      attribute :year, :integer
      attribute :organisation_id, :integer

      validates :year, presence: true

      def view_path
        "bulk_upload_#{log_type}_logs/forms/year"
      end

      def options
        possible_years.map do |year|
          OpenStruct.new(id: year, name: "#{year} to #{year + 1}")
        end
      end

      def back_path
        if organisation_id.present?
          send("#{log_type}_logs_organisation_path", organisation_id)
        else
          send("#{log_type}_logs_path")
        end
      end

      def next_path
        send("bulk_upload_#{log_type}_log_path", id: "prepare-your-file", form: { year:, organisation_id: }.compact)
      end

      def save!
        true
      end

    private

      def possible_years
        [
          FormHandler.instance.send("#{log_type}_forms")["current_#{log_type}"].start_date.year,
          (FormHandler.instance.send("previous_#{log_type}_form").start_date.year if FormHandler.instance.send("#{log_type}_in_crossover_period?")),
          (FormHandler.instance.send("next_#{log_type}_form").start_date.year if FeatureToggle.allow_future_form_use?),
        ].compact
      end
    end
  end
end
