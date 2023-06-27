module Csv
  class LettingsLogCsvService
    def initialize(user:, export_type:)
      @user = user
      @export_type = export_type
      @attributes = lettings_log_attributes
    end

    def prepare_csv(logs)
      CSV.generate(headers: true) do |csv|
        csv << @attributes

        logs.find_each do |log|
          csv << @attributes.map { |attribute| value(attribute, log) }
        end
      end
    end

  private

    CUSTOM_CALL_CHAINS = {
      created_by: {
        labels: %i[created_by email],
        codes: %i[created_by email],
      },
      updated_by: {
        labels: %i[updated_by email],
        codes: %i[updated_by email],
      },
      location_code: {
        labels: %i[location id],
        codes: %i[location id],
      },
      location_postcode: {
        labels: %i[location postcode],
        codes: %i[location postcode],
      },
      location_name: {
        labels: %i[location name],
        codes: %i[location name],
      },
      location_units: {
        labels: %i[location units],
        codes: %i[location units],
      },
      location_type_of_unit: {
        labels: %i[location type_of_unit],
        codes: %i[location type_of_unit_before_type_cast],
      },
      location_mobility_type: {
        labels: %i[location mobility_type],
        codes: %i[location mobility_type_before_type_cast],
      },
      location_admin_district: {
        labels: %i[location location_admin_district],
        codes: %i[location location_admin_district],
      },
      location_startdate: {
        labels: %i[location startdate],
        codes: %i[location startdate],
      },
      scheme_service_name: {
        labels: %i[scheme service_name],
        codes: %i[scheme service_name],
      },
      scheme_sensitive: {
        labels: %i[scheme sensitive],
        codes: %i[scheme sensitive_before_type_cast],
      },
      SCHTYPE: {
        labels: %i[scheme scheme_type],
        codes: %i[scheme scheme_type_before_type_cast],
      },
      scheme_registered_under_care_act: {
        labels: %i[scheme registered_under_care_act],
        codes: %i[scheme registered_under_care_act_before_type_cast],
      },
      scheme_owning_organisation_name: {
        labels: %i[scheme owning_organisation name],
        codes: %i[scheme owning_organisation name],
      },
      scheme_primary_client_group: {
        labels: %i[scheme primary_client_group],
        codes: %i[scheme primary_client_group_before_type_cast],
      },
      scheme_has_other_client_group: {
        labels: %i[scheme has_other_client_group],
        codes: %i[scheme has_other_client_group_before_type_cast],
      },
      scheme_secondary_client_group: {
        labels: %i[scheme secondary_client_group],
        codes: %i[scheme secondary_client_group_before_type_cast],
      },
      scheme_support_type: {
        labels: %i[scheme support_type],
        codes: %i[scheme support_type_before_type_cast],
      },
      scheme_intended_stay: {
        labels: %i[scheme intended_stay],
        codes: %i[scheme intended_stay_before_type_cast],
      },
      scheme_created_at: {
        labels: %i[scheme created_at],
        codes: %i[scheme created_at],
      },
      scheme_code: {
        labels: %i[scheme id_to_display],
        codes: %i[scheme id_to_display],
      },
      creation_method: {
        labels: %i[creation_method_label],
        codes: %i[creation_method_code],
      },
      is_dpo: {
        labels: %i[created_by is_dpo?],
        codes: %i[created_by is_dpo?],
      },
    }.freeze

    FIELDS_ALWAYS_EXPORTED_AS_CODES = %w[
      la
      prevloc
    ].freeze

    FIELDS_ALWAYS_EXPORTED_AS_LABELS = {
      "la_label" => "la",
      "prevloc_label" => "prevloc",
    }.freeze

    DATE_FIELDS = %w[
      mrcdate
      startdate
      voiddate
      created_at
      updated_at
    ].freeze

    def value(attribute, log)
      attribute = "rent_type" if attribute == "rent_type_detail" # rent_type_detail is the requested column header for rent_type, so as not to confuse with renttype. It can be exported as label or code.
      if CUSTOM_CALL_CHAINS.key? attribute.to_sym
        call_chain = CUSTOM_CALL_CHAINS[attribute.to_sym][@export_type.to_sym]
        call_chain.reduce(log) { |object, next_call| object&.public_send(next_call) }
      elsif FIELDS_ALWAYS_EXPORTED_AS_CODES.include? attribute
        log.public_send(attribute)
      elsif FIELDS_ALWAYS_EXPORTED_AS_LABELS.key? attribute
        attribute = FIELDS_ALWAYS_EXPORTED_AS_LABELS[attribute]
        value = log.public_send(attribute)
        get_label(value, attribute, log)
      elsif DATE_FIELDS.include? attribute
        log.public_send(attribute)&.iso8601
      else
        value = log.public_send(attribute)
        case @export_type
        when "codes"
          value
        when "labels"
          answer_label = get_label(value, attribute, log)
          answer_label || label_if_boolean_value(value) || value
        end
      end
    end

    def get_label(value, attribute, log)
      log.form
         .get_question(attribute, log)
         &.label_from_value(value)
    end

    def label_if_boolean_value(value)
      return "Yes" if value == true
      return "No" if value == false
    end

    ATTRIBUTE_MAPPINGS = {
      "owning_organisation_id" => %w[owning_organisation_name],
      "managing_organisation_id" => %w[managing_organisation_name],
      "created_by_id" => [],
      "scheme_id" => [],
      "location_id" => [],
      "rent_type" => %w[renttype rent_type_detail],
      "hb" => %w[hb has_benefits],
      "age1" => %w[refused hhtype totchild totelder totadult age1],
      "housingneeds_type" => %w[housingneeds_type housingneeds_a housingneeds_b housingneeds_c housingneeds_f housingneeds_g housingneeds_h],
      "net_income_known" => %w[net_income_known incref],
      "irproduct_other" => %w[irproduct irproduct_other lar],
      "la" => %w[is_la_inferred la_label la],
      "prevloc" => %w[is_previous_la_inferred prevloc_label prevloc],
      "needstype" => %w[needstype lettype],
      "prevten" => %w[prevten new_old],
      "voiddate" => %w[voiddate vacdays],
      "rsnvac" => %w[rsnvac newprop],
      "household_charge" => %w[household_charge nocharge],
      "brent" => %w[brent wrent],
      "scharge" => %w[scharge wscharge],
      "pscharge" => %w[pscharge wpschrge],
      "supcharg" => %w[supcharg wsupchrg],
      "tcharge" => %w[tcharge wtcharge],
      "chcharge" => %w[chcharge wchchrg],
      "tshortfall" => %w[tshortfall wtshortfall],
    }.freeze

    SUPPORT_ONLY_ATTRIBUTES = %w[hhmemb net_income_value_check first_time_property_let_as_social_housing renttype needstype postcode_known is_la_inferred totchild totelder totadult net_income_known is_carehome previous_la_known is_previous_la_inferred age1_known age2_known age3_known age4_known age5_known age6_known age7_known age8_known letting_allocation_unknown details_known_2 details_known_3 details_known_4 details_known_5 details_known_6 details_known_7 details_known_8 rent_type_detail wrent wscharge wpschrge wsupchrg wtcharge wtshortfall rent_value_check old_form_id old_id retirement_value_check tshortfall_known pregnancy_value_check hhtype new_old vacdays la prevloc updated_by_id bulk_upload_id uprn_confirmed].freeze

    def lettings_log_attributes
      ordered_questions = FormHandler.instance.ordered_lettings_questions_for_all_years
      attributes = ordered_questions.flat_map do |question|
        if question.type == "checkbox"
          question.answer_options.keys.reject { |key| key == "divider" }
        elsif ATTRIBUTE_MAPPINGS.key? question.id
          ATTRIBUTE_MAPPINGS[question.id]
        else
          question.id
        end
      end
      non_question_fields = %w[id status created_by is_dpo created_at updated_by updated_at creation_method old_id old_form_id collection_start_year]
      scheme_and_location_attributes = %w[scheme_code scheme_service_name scheme_sensitive SCHTYPE scheme_registered_under_care_act scheme_owning_organisation_name scheme_primary_client_group scheme_has_other_client_group scheme_secondary_client_group scheme_support_type scheme_intended_stay scheme_created_at location_code location_postcode location_name location_units location_type_of_unit location_mobility_type location_admin_district location_startdate]
      final_attributes = non_question_fields + attributes + scheme_and_location_attributes
      @user.support? ? final_attributes : final_attributes - SUPPORT_ONLY_ATTRIBUTES
    end
  end
end
