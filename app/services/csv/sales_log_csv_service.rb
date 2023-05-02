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
      day: %i[saledate day],
      month: %i[saledate month],
      year: %i[saledate year],
      is_dpo: %i[created_by is_dpo],
      created_by_name: %i[created_by name],
      owning_organisation_name: %i[owning_organisation name],
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
      created_at
      updated_at
    ].freeze

    def value(attribute, log)
      if ATTRIBUTES_OF_RELATED_OBJECTS.key? attribute.to_sym
        call_chain = ATTRIBUTES_OF_RELATED_OBJECTS[attribute.to_sym]
        call_chain.reduce(log) { |object, next_call| object&.public_send(next_call) }
      elsif FIELDS_ALWAYS_EXPORTED_AS_CODES.include? attribute
        log.send(attribute)
      elsif FIELDS_ALWAYS_EXPORTED_AS_LABELS.key? attribute
        attribute = FIELDS_ALWAYS_EXPORTED_AS_LABELS[attribute]
        field_value = log.send(attribute)
        get_label(field_value, attribute, log)
      elsif DATE_FIELDS.include? attribute
        log.send(attribute)&.iso8601
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
      "saledate" => %w[day month year],
      "exdate" => %w[exday exmonth exyear],
      "hodate" => %w[hoday homonth hoyear],
      "postcode_full" => %w[pcode1 pcode2],
      "ppostcode_full" => %w[ppostc1 ppostc2],
      "la" => %w[la la_label],
      "prevloc" => %w[prevloc prevloc_label],
      "created_by_id" => %w[created_by_name],
      "owning_organisation_id" => %w[owning_organisation_name],
    }.freeze

    def sales_log_attributes
      ordered_questions = FormHandler.instance.ordered_sales_questions_for_all_years
      ordered_questions.reject! { |q| q.id.match?(/((?<!la)_known)|(_check)|(_asked)/) }
      attributes = ordered_questions.flat_map do |question|
        if question.type == "checkbox"
          question.answer_options.keys
        elsif ATTRIBUTE_MAPPINGS.key? question.id
          ATTRIBUTE_MAPPINGS[question.id]
        else
          question.id
        end
      end
      non_question_fields = %w[id status created_at updated_at old_id collection_start_year creation_method is_dpo]
      non_question_fields + attributes
    end
  end
end
