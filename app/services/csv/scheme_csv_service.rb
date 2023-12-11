module Csv
  class SchemeCsvService
    def initialize(user:)
      @user = user
      @attributes = scheme_attributes
    end

    def prepare_csv(schemes)
      CSV.generate(headers: true) do |csv|
        csv << @attributes

        schemes.find_each do |scheme|
          csv << @attributes.map { |attribute| value(attribute, scheme) }
        end
      end
    end

  private

    def value(attribute, log)
      log.public_send(attribute)
    end

    def scheme_attributes
      %w[scheme_code scheme_service_name scheme_status scheme_sensitive scheme_type scheme_registered_under_care_act scheme_owning_organisation_name scheme_support_services_provided_by scheme_primary_client_group scheme_has_other_client_group scheme_secondary_client_group scheme_support_type scheme_intended_stay scheme_created_at scheme_active_dates]
    end
  end
end
