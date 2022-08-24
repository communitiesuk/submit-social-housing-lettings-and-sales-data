module Csv
  class CaseLogCsvService
    CSV_FIELDS_TO_OMIT = %w[hhmemb net_income_value_check sale_or_letting first_time_property_let_as_social_housing renttype needstype postcode_known is_la_inferred totchild totelder totadult net_income_known is_carehome previous_la_known is_previous_la_inferred age1_known age2_known age3_known age4_known age5_known age6_known age7_known age8_known letting_allocation_unknown details_known_2 details_known_3 details_known_4 details_known_5 details_known_6 details_known_7 details_known_8 rent_type wrent wscharge wpschrge wsupchrg wtcharge wtshortfall rent_value_check old_form_id old_id retirement_value_check tshortfall_known pregnancy_value_check hhtype new_old vacdays].freeze

    def initialize(user)
      @user = user
      set_csv_attributes
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << @attributes

        CaseLog.all.find_each do |record|
          csv << @attributes.map do |att|
            record.form.get_question(att, record)&.label_from_value(record.send(att)) || label_from_value(record.send(att))
          end
        end
      end
    end

  private

    def label_from_value(value)
      return "Yes" if value == true
      return "No" if value == false

      value
    end

    def set_csv_attributes
      metadata_fields = %w[id status created_at updated_at created_by_name is_dpo owning_organisation_name managing_organisation_name]
      metadata_id_fields = %w[managing_organisation_id owning_organisation_id created_by_id]
      scheme_attributes = %w[scheme_id location_id]
      intersecting_attributes = ordered_form_questions & CaseLog.attribute_names - scheme_attributes
      remaining_attributes = CaseLog.attribute_names - intersecting_attributes - scheme_attributes

      @attributes = (metadata_fields + intersecting_attributes + remaining_attributes - metadata_id_fields + %w[unittype_sh] + scheme_attributes).uniq
      move_is_inferred_fields

      @attributes -= CSV_FIELDS_TO_OMIT if @user.present? && !@user.support?
    end

    def ordered_form_questions
      downloaded_form_years = CaseLog.all.map(&:collection_start_year).uniq.compact
      downloaded_form_fields = downloaded_form_years.count == 1 && downloaded_form_years[0].present? ? FormHandler.instance.get_form("#{downloaded_form_years[0]}_#{downloaded_form_years[0] + 1}").questions : FormHandler.instance.forms.first.second.questions
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

    def move_is_inferred_fields
      { la: "is_la_inferred", prevloc: "is_previous_la_inferred" }.each do |inferred_field, field|
        @attributes.delete(field)
        @attributes.insert(@attributes.find_index(inferred_field.to_s), field)
      end
    end
  end
end
