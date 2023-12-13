module Csv
  class SchemeCsvService
    include SchemesHelper
    include LocationsHelper

    def initialize(download_type:)
      @download_type = download_type
    end

    def prepare_csv(schemes)
      CSV.generate(headers: true) do |csv|
        csv << attributes
        schemes.find_each do |scheme|
          if @download_type == "schemes"
            csv << scheme_attributes.map { |attribute| scheme_value(attribute, scheme) }
          else
            scheme.locations.each do |location|
              case @download_type
              when "locations"
                csv << [scheme.id_to_display] + location_attributes.map { |attribute| location_value(attribute, location) }
              when "combined"
                csv << scheme_attributes.map { |attribute| scheme_value(attribute, scheme) } + location_attributes.map { |attribute| location_value(attribute, location) }
              end
            end
          end
        end
      end
    end

  private

    SCHEME_FIELD_FROM_ATTRIBUTE = {
      "scheme_code" => "id_to_display",
      "scheme_service_name" => "service_name",
      "scheme_status" => "status",
      "scheme_sensitive" => "sensitive",
      "scheme_registered_under_care_act" => "registered_under_care_act",
      "scheme_support_services_provided_by" => "arrangement_type",
      "scheme_primary_client_group" => "primary_client_group",
      "scheme_has_other_client_group" => "has_other_client_group",
      "scheme_secondary_client_group" => "secondary_client_group",
      "scheme_support_type" => "support_type",
      "scheme_intended_stay" => "intended_stay",
      "scheme_created_at" => "created_at",
    }.freeze

    LOCATION_FIELD_FROM_ATTRIBUTE = {
      "location_code" => "id",
      "location_postcode" => "postcode",
      "location_name" => "name",
      "location_status" => "status",
      "location_local_authority" => "location_admin_district",
      "location_units" => "units",
      "location_type_of_unit" => "type_of_unit",
      "location_mobility_type" => "mobility_type",
    }.freeze

    CUSTOM_CALL_CHAINS = {
      scheme_owning_organisation_name: %i[owning_organisation name],
    }.freeze

    SYSTEM_DATE_FIELDS = %w[
      created_at
    ].freeze

    def scheme_value(attribute, scheme)
      attribute = SCHEME_FIELD_FROM_ATTRIBUTE.fetch(attribute, attribute)
      if attribute == "scheme_active_dates"
        scheme_availability(scheme)
      elsif CUSTOM_CALL_CHAINS.key? attribute.to_sym
        call_chain = CUSTOM_CALL_CHAINS[attribute.to_sym]
        call_chain.reduce(scheme) { |object, next_call| object&.public_send(next_call) }
      elsif SYSTEM_DATE_FIELDS.include? attribute
        scheme.public_send(attribute)&.iso8601
      else
        scheme.public_send(attribute)
      end
    end

    def location_value(attribute, location)
      attribute = LOCATION_FIELD_FROM_ATTRIBUTE.fetch(attribute, attribute)
      if attribute == "location_active_dates"
        location_availability(location)
      else
        location.public_send(attribute)
      end
    end

    def scheme_attributes
      %w[scheme_code scheme_service_name scheme_status scheme_sensitive scheme_type scheme_registered_under_care_act scheme_owning_organisation_name scheme_support_services_provided_by scheme_primary_client_group scheme_has_other_client_group scheme_secondary_client_group scheme_support_type scheme_intended_stay scheme_created_at scheme_active_dates]
    end

    def location_attributes
      %w[location_code location_postcode location_name location_status location_local_authority location_units location_type_of_unit location_mobility_type location_active_dates]
    end

    def attributes
      case @download_type
      when "schemes"
        scheme_attributes
      when "locations"
        %w[scheme_code] + location_attributes
      when "combined"
        scheme_attributes + location_attributes
      end
    end
  end
end
