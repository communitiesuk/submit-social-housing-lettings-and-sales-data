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

    CUSTOM_CALL_CHAINS = {
      day: {
        labels: %i[saledate day],
        codes: %i[saledate day],
      },
      month: {
        labels: %i[saledate month],
        codes: %i[saledate month],
      },
      year: {
        labels: %i[saledate year],
        codes: %i[saledate year],
      },
      is_dpo: {
        labels: %i[created_by is_dpo],
        codes: %i[created_by is_dpo],
      },
      created_by: {
        labels: %i[created_by email],
        codes: %i[created_by email],
      },
      owning_organisation_name: {
        labels: %i[owning_organisation name],
        codes: %i[owning_organisation name],
      },
      creation_method: {
        labels: %i[creation_method],
        codes: %i[creation_method_before_type_cast],
      },
    }.freeze

    PERSON_DETAILS = {}.tap { |hash|
      hash["age1"] = { "refused_code" => "-9", "refused_label" => "Not known", "age_known_field" => "age1_known" }
      (2..6).each do |i|
        hash["age#{i}"] = { "refused_code" => "-9", "refused_label" => "Not known", "details_known_field" => "details_known_#{i}", "age_known_field" => "age#{i}_known" }
        hash["sex#{i}"] = { "refused_code" => "R", "refused_label" => "Prefers not to say", "details_known_field" => "details_known_#{i}" }
        hash["relat#{i}"] = { "refused_code" => "R", "refused_label" => "Prefers not to say", "details_known_field" => "details_known_#{i}" }
        hash["ecstat#{i}"] = { "refused_code" => "10", "refused_label" => "Prefers not to say", "details_known_field" => "details_known_#{i}" }
      end
    }.freeze

    FIELDS_ALWAYS_EXPORTED_AS_CODES = %w[
      la
      prevloc
    ].freeze

    FIELDS_ALWAYS_EXPORTED_AS_LABELS = {
      "la_label" => "la",
      "prevloc_label" => "prevloc",
    }.freeze

    SYSTEM_DATE_FIELDS = %w[
      created_at
      updated_at
    ].freeze

    def value(attribute, log)
      if CUSTOM_CALL_CHAINS.key? attribute.to_sym
        call_chain = CUSTOM_CALL_CHAINS[attribute.to_sym][@export_type.to_sym]
        call_chain.reduce(log) { |object, next_call| object&.public_send(next_call) }
      elsif FIELDS_ALWAYS_EXPORTED_AS_CODES.include? attribute
        log.send(attribute)
      elsif FIELDS_ALWAYS_EXPORTED_AS_LABELS.key? attribute
        attribute = FIELDS_ALWAYS_EXPORTED_AS_LABELS[attribute]
        value = log.send(attribute)
        get_label(value, attribute, log)
      elsif SYSTEM_DATE_FIELDS.include? attribute
        log.public_send(attribute)&.iso8601
      elsif PERSON_DETAILS.any? { |key, _value| key == attribute } && (person_details_not_known?(log, attribute) || age_not_known?(log, attribute))
        case @export_type
        when "codes"
          PERSON_DETAILS.find { |key, _value| key == attribute }[1]["refused_code"]
        when "labels"
          PERSON_DETAILS.find { |key, _value| key == attribute }[1]["refused_label"]
        end
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
      "created_by_id" => %w[created_by],
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
      non_question_fields = %w[id status created_at updated_at old_form_id collection_start_year creation_method is_dpo]
      non_question_fields + attributes
    end

    def person_details_not_known?(log, attribute)
      details_known_field = PERSON_DETAILS.find { |key, _value| key == attribute }[1]["details_known_field"]
      log[details_known_field] == 2 # 1 for lettings logs, 2 for sales logs
    end

    def age_not_known?(log, attribute)
      age_known_field = PERSON_DETAILS.find { |key, _value| key == attribute }[1]["age_known_field"]
      log[age_known_field] == 1
    end
  end
end
