module Csv
  class LettingsLogCsvService
    CSV_FIELDS_TO_OMIT = %w[hhmemb net_income_value_check first_time_property_let_as_social_housing renttype needstype postcode_known is_la_inferred totchild totelder totadult net_income_known is_carehome previous_la_known is_previous_la_inferred age1_known age2_known age3_known age4_known age5_known age6_known age7_known age8_known letting_allocation_unknown details_known_2 details_known_3 details_known_4 details_known_5 details_known_6 details_known_7 details_known_8 rent_type_detail wrent wscharge wpschrge wsupchrg wtcharge wtshortfall rent_value_check old_form_id old_id retirement_value_check tshortfall_known pregnancy_value_check hhtype new_old vacdays la prevloc unresolved updated_by_id bulk_upload_id].freeze

    def initialize(user)
      @user = user
      set_csv_attributes
    end

    def to_csv(is_codes_only_export:)
      CSV.generate(headers: true) do |csv|
        csv << @attributes

        LettingsLog.all.find_each do |record|
          csv << @attributes.map do |att|
            label_from_value(record, att, is_codes_only_export:)
          end
        end
      end
    end

  private

    def label_from_value(record, att, is_codes_only_export:)
      if %w[la prevloc].include? att
        record.send(att)
      elsif %w[mrcdate startdate voiddate].include? att
        record.send(att)&.to_formatted_s(:govuk_date)
      elsif is_codes_only_export && att.start_with?("location_", "scheme_")
        att += "_before_type_cast" unless %w[location_code scheme_code scheme_owning_organisation_name scheme_created_at location_startdate].include? att
        record.send(att)
      else
        att = att.remove("_label", "_detail") # a couple of csv column headers have suffixes for the user that are not reflected in the app domain
        field_value = record.send(att)
        answer_label = record.form
                             .get_question(att, record)
                             &.label_from_value(field_value)
        if is_codes_only_export
          field_value
        else
          answer_label || label_if_boolean_value(field_value) || field_value
        end
      end
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
