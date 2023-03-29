module Csv
  class LettingsLogCsvService
    CSV_FIELDS_TO_OMIT = %w[hhmemb net_income_value_check first_time_property_let_as_social_housing renttype needstype postcode_known is_la_inferred totchild totelder totadult net_income_known is_carehome previous_la_known is_previous_la_inferred age1_known age2_known age3_known age4_known age5_known age6_known age7_known age8_known letting_allocation_unknown details_known_2 details_known_3 details_known_4 details_known_5 details_known_6 details_known_7 details_known_8 rent_type_detail wrent wscharge wpschrge wsupchrg wtcharge wtshortfall rent_value_check old_form_id old_id retirement_value_check tshortfall_known pregnancy_value_check hhtype new_old vacdays la prevloc unresolved updated_by_id bulk_upload_id uprn_confirmed visible].freeze

    def initialize(user, export_type:)
      @user = user
      @export_type = export_type
      set_csv_attributes
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << @attributes

        LettingsLog.all.find_each do |record|
          csv << @attributes.map { |attribute| get_value(attribute, record) }
        end
      end
    end

  private

    ATTRIBUTES_OF_RELATED_OBJECTS = {
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
      scheme_type: {
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
    }.freeze

    def get_value(attribute, record)
      attribute = "rent_type" if attribute == "rent_type_detail" # rent_type_detail is the requested column header for rent_type, so as not to confuse with renttype
      if ATTRIBUTES_OF_RELATED_OBJECTS.key? attribute.to_sym
        call_chain = ATTRIBUTES_OF_RELATED_OBJECTS[attribute.to_sym][@export_type.to_sym]
        call_chain.reduce(record) { |object, next_call| object&.send(next_call) }
      elsif %w[la prevloc].include? attribute # for all exports we output both the codes and labels for these location attributes
        record.send(attribute)
      elsif %w[la_label prevloc_label].include? attribute # as above
        attribute = attribute.remove("_label")
        field_value = record.send(attribute)
        get_label(field_value, attribute, record)
      elsif %w[mrcdate startdate voiddate].include? attribute
        record.send(attribute)&.to_formatted_s(:govuk_date)
      else
        field_value = record.send(attribute)
        case @export_type
        when "codes"
          field_value
        when "labels"
          answer_label = get_label(field_value, attribute, record)
          answer_label || label_if_boolean_value(field_value) || field_value
        end
      end
    end

    def get_label(value, attribute, record)
      record.form
            .get_question(attribute, record)
            &.label_from_value(value)
    end

    def label_if_boolean_value(value)
      return "Yes" if value == true
      return "No" if value == false
    end

    def set_csv_attributes
      metadata_fields = %w[id status created_at updated_at created_by_name is_dpo owning_organisation_name managing_organisation_name collection_start_year]
      metadata_id_fields = %w[managing_organisation_id owning_organisation_id created_by_id bulk_upload_id]
      scheme_and_location_ids = %w[scheme_id location_id]
      scheme_attributes = %w[scheme_code scheme_service_name scheme_sensitive scheme_type scheme_registered_under_care_act scheme_owning_organisation_name scheme_primary_client_group scheme_has_other_client_group scheme_secondary_client_group scheme_support_type scheme_intended_stay scheme_created_at]
      location_attributes = %w[location_code location_postcode location_name location_units location_type_of_unit location_mobility_type location_admin_district location_startdate]
      intersecting_attributes = ordered_form_questions & LettingsLog.attribute_names - scheme_and_location_ids
      remaining_attributes = LettingsLog.attribute_names - intersecting_attributes - scheme_and_location_ids

      @attributes = (metadata_fields + intersecting_attributes + remaining_attributes - metadata_id_fields + %w[unittype_sh] + scheme_attributes + location_attributes).uniq
      move_la_fields
      rename_attributes

      @attributes -= CSV_FIELDS_TO_OMIT if @user.present? && !@user.support?
    end

    def ordered_form_questions
      downloaded_form_years = LettingsLog.all.map(&:collection_start_year).uniq.compact

      if downloaded_form_years.count == 1 && downloaded_form_years[0].present?
        form_name = FormHandler.instance.form_name_from_start_year(downloaded_form_years[0], "lettings")
        downloaded_form_fields = FormHandler.instance.get_form(form_name).questions
      else
        downloaded_form_fields = FormHandler.instance.current_lettings_form.questions
      end
      move_checkbox_answer_options(downloaded_form_fields)
    end

    def move_checkbox_answer_options(form_questions)
      checkboxes = form_questions.filter { |question| question.type == "checkbox" }.map { |question| { "#{question.id}": question.answer_options.keys } }
      attributes = form_questions.map(&:id).uniq

      checkboxes.each do |checkbox_question|
        checkbox_question.values[0].each do |answer_option|
          attributes.insert(attributes.find_index(checkbox_question.keys[0].to_s), answer_option)
        end
      end
      attributes
    end

    def move_la_fields
      { la: %w[is_la_inferred la_label], prevloc: %w[is_previous_la_inferred prevloc_label] }.each do |inferred_field, fields|
        fields.each do |field|
          @attributes.delete(field)
          @attributes.insert(@attributes.find_index(inferred_field.to_s), field)
        end
      end
    end

    def rename_attributes
      { "rent_type" => "rent_type_detail" }.each do |original_field, new_field|
        @attributes.insert(@attributes.find_index(original_field), new_field)
        @attributes.delete(original_field)
      end
    end
  end
end
