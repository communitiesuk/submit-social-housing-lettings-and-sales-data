module Csv
  class SalesLogCsvService
    def initialize(export_type:)
      @export_type = export_type
      @attributes = sales_log_attributes
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

    ATTRIBUTES_OF_RELATED_OBJECTS = {
      created_by_name: %i[created_by name],
      is_dpo: %i[created_by is_dpo],
      owning_organisation_name: %i[owning_organisation name],
    }.freeze

    # can this be made so general it can also be extracted? quite possibly
    def value(attribute, log)
      if ATTRIBUTES_OF_RELATED_OBJECTS.key? attribute.to_sym
        call_chain = ATTRIBUTES_OF_RELATED_OBJECTS[attribute.to_sym]
        call_chain.reduce(log) { |object, next_call| object&.public_send(next_call) }
      elsif %w[la prevloc].include? attribute # for all exports we output both the codes and labels for these location attributes
        log.send(attribute)
      elsif %w[la_label prevloc_label].include? attribute # as above
        attribute = attribute.remove("_label")
        field_value = log.send(attribute)
        get_label(field_value, attribute, log)
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

    # extract - common to lettings log csv service
    def get_label(value, attribute, log)
      log.form
         .get_question(attribute, log)
         &.label_from_value(value)
    end

    # also extract
    def label_if_boolean_value(value)
      return "Yes" if value == true
      return "No" if value == false
    end

    ATTRIBUTE_MAPPINGS = {
      "exdate" => %w[exday exmonth exyear],
      "hodate" => %w[hoday homonth hoyear],
      "postcode_full" => %w[pcode1 pcode2],
      "ppostcode_full" => %w[ppostc1 ppostc2],
      "la" => %w[la la_label],
      "prevloc" => %w[prevloc prevloc_label],
    }.freeze

    def sales_log_attributes
      ordered_questions = FormHandler.instance.ordered_sales_questions_for_all_years
      ordered_questions.reject! { |q| q.id.match?(/((?<!la)_known)|(_value_check)/) }
      attributes = ordered_questions.flat_map do |question|
        if question.type == "checkbox"
          question.answer_options.keys
        elsif ATTRIBUTE_MAPPINGS.key? question.id
          ATTRIBUTE_MAPPINGS[question.id]
        else
          question.id
        end
      end
      non_question_fields = %w[id status created_at updated_at created_by_name is_dpo owning_organisation_name collection_start_year creation_method]
      non_question_fields + attributes
    end
  end
end
