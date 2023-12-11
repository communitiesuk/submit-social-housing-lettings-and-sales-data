module Csv
  class SchemeCsvService
    include SchemesHelper

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

    FIELD_FROM_ATTRIBUTE = {
      "scheme_code" => %w[id_to_display],
      "scheme_service_name" => %w[service_name],
      "scheme_status" => %w[status],
      "scheme_sensitive" => %w[sensitive],
      "scheme_registered_under_care_act" => %w[registered_under_care_act],
      "scheme_support_services_provided_by" => %w[arrangement_type],
      "scheme_primary_client_group" => %w[primary_client_group],
      "scheme_has_other_client_group" => %w[has_other_client_group],
      "scheme_secondary_client_group" => %w[secondary_client_group],
      "scheme_support_type" => %w[support_type],
      "scheme_intended_stay" => %w[intended_stay],
      "scheme_created_at" => %w[created_at],
    }.freeze

    CUSTOM_CALL_CHAINS = {
      scheme_owning_organisation_name: %i[owning_organisation name],
    }.freeze

    SYSTEM_DATE_FIELDS = %w[
      created_at
    ].freeze

    def value(attribute, scheme)
      attribute = FIELD_FROM_ATTRIBUTE.fetch(attribute, attribute)
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


    def scheme_attributes
      %w[scheme_code scheme_service_name scheme_status scheme_sensitive scheme_type scheme_registered_under_care_act scheme_owning_organisation_name scheme_support_services_provided_by scheme_primary_client_group scheme_has_other_client_group scheme_secondary_client_group scheme_support_type scheme_intended_stay scheme_created_at scheme_active_dates]
    end
  end
end
