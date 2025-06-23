module Csv
  class SalesLogCsvService
    def initialize(user:, export_type:, year:)
      @user = user
      @export_type = export_type
      @year = year
      @attributes = sales_log_attributes
      @definitions = sales_log_definitions
    end

    def prepare_csv(logs)
      CSV.generate(headers: true) do |csv|
        formatted_attributes = formatted_attribute_headers
        if @year >= 2023
          csv << formatted_attributes.map do |attribute|
            record = @definitions.find { |r| r.variable == attribute.downcase }
            record&.tap { |r| r.update!(last_accessed: Time.zone.now) }&.definition
          end
        end
        csv << formatted_attributes

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
        labels: %i[assigned_to is_dpo],
        codes: %i[assigned_to is_dpo],
      },
      assigned_to: {
        labels: %i[assigned_to email],
        codes: %i[assigned_to email],
      },
      created_by: {
        labels: %i[created_by email],
        codes: %i[created_by email],
      },
      owning_organisation_name: {
        labels: %i[owning_organisation name],
        codes: %i[owning_organisation name],
      },
      managing_organisation_name: {
        labels: %i[managing_organisation name],
        codes: %i[managing_organisation name],
      },
      creation_method: {
        labels: %i[creation_method],
        codes: %i[creation_method_before_type_cast],
      },
      mscharge_value_check: {
        labels: %i[monthly_charges_value_check],
        codes: %i[monthly_charges_value_check],
      },
      stairlastday: {
        labels: %i[lasttransaction day],
        codes: %i[lasttransaction day],
      },
      stairlastmonth: {
        labels: %i[lasttransaction month],
        codes: %i[lasttransaction month],
      },
      stairlastyear: {
        labels: %i[lasttransaction year],
        codes: %i[lasttransaction year],
      },
      stairinitialday: {
        labels: %i[initialpurchase day],
        codes: %i[initialpurchase day],
      },
      stairinitialmonth: {
        labels: %i[initialpurchase month],
        codes: %i[initialpurchase month],
      },
      stairinitialyear: {
        labels: %i[initialpurchase year],
        codes: %i[initialpurchase year],
      },
      has_servicecharges: {
        labels: %i[has_servicecharge_label],
        codes: %i[has_servicecharge],
      },
      servicecharges: {
        labels: %i[servicecharge],
        codes: %i[servicecharge],
      },
      has_mscharge: {
        labels: %i[has_mscharge_label],
        codes: %i[has_mscharge_value],
      },
      mscharge: {
        labels: %i[mscharge_value],
        codes: %i[mscharge_value],
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

    ORDERED_ADDRESS_FIELDS = %w[uprn address_line1 address_line2 town_or_city county postcode_full is_la_inferred la_label la uprn_selection address_search_value_check address_line1_input postcode_full_input address_line1_as_entered address_line2_as_entered town_or_city_as_entered county_as_entered postcode_full_as_entered la_as_entered].freeze

    SUPPORT_ONLY_ATTRIBUTES = %w[address_line1_as_entered address_line2_as_entered town_or_city_as_entered county_as_entered postcode_full_as_entered la_as_entered created_by created_by_id value_value_check mscharge_value_check].freeze

    SUPPORT_ATTRIBUTE_NAME_MAPPINGS = {
      "duplicate_set_id" => "DUPLICATESET",
      "bulk_upload_id" => "BULKUPLOADID",
      "created_at" => "CREATEDDATE",
      "updated_at" => "UPLOADDATE",
      "old_form_id" => "FORM",
      "collection_start_year" => "COLLECTIONYEAR",
      "creation_method" => "CREATIONMETHOD",
      "is_dpo" => "DATAPROTECT",
      "created_by" => "CREATEDBY",
      "owning_organisation_name" => "OWNINGORGNAME",
      "managing_organisation_name" => "MANINGORGNAME",
      "assigned_to" => "USERNAME",
      "ownershipsch" => "OWNERSHIP",
      "companybuy" => "COMPANY",
      "buylivein" => "LIVEINBUYER",
      "jointpur" => "JOINT",
      "address_line1" => "ADDRESS1",
      "address_line2" => "ADDRESS2",
      "town_or_city" => "TOWNCITY",
      "postcode_full" => "POSTCODE",
      "is_la_inferred" => "ISLAINFERRED",
      "la_label" => "LANAME",
      "uprn_selection" => "UPRNSELECTED",
      "address_line1_input" => "ADDRESS1INPUT",
      "postcode_full_input" => "POSTCODEINPUT",
      "address_line1_as_entered" => "BULKADDRESS1",
      "address_line2_as_entered" => "BULKADDRESS2",
      "town_or_city_as_entered" => "BULKTOWNCITY",
      "county_as_entered" => "BULKCOUNTY",
      "postcode_full_as_entered" => "BULKPOSTCODE",
      "la_as_entered" => "BULKLA",
      "ethnic_group" => "ETHNICGROUP1",
      "nationality_all" => "NATIONALITYALL1",
      "buy1livein" => "LIVEINBUYER1",
      "ethnic_group2" => "ETHNICGROUP2",
      "ethnicbuy2" => "ETHNIC2",
      "nationality_all_buyer2" => "NATIONALITYALL2",
      "buy2livein" => "LIVEINBUYER2",
      "hholdcount" => "HHTYPE",
      "previous_la_known" => "PREVIOUSLAKNOWN",
      "prevloc_label" => "PREVLOCNAME",
      "prevtenbuy2" => "PREVTEN2",
      "income1nk" => "INC1NK",
      "income2nk" => "INC2NK",
      "staircasesale" => "STAIRCASETOSALE",
      "soctenant" => "SOCTEN",
      "mortlen" => "MORTLEN1",
      "has_mscharge" => "HASMSCHARGE",
      "nationalbuy2" => "NATIONAL2",
      "uprn_confirmed" => "UPRNCONFIRMED",
    }.freeze

    SUPPORT_ATTRIBUTE_NAME_MAPPINGS_2025 = {
      "hholdcount" => "HHOLDCOUNT",
      "created_by_id" => "CREATEDBYID",
      "owning_organisation_id" => "OWNINGORGID",
      "managing_organisation_id" => "MANINGORGID",
      "assigned_to_id" => "USERNAMEID",
      "updated_by" => "AMENDEDBY",
      "updated_by_id" => "AMENDEDBYID",
      "has_management_fee" => "HASESTATEFEE",
      "management_fee" => "ESTATEFEE",
      "has_servicecharges" => "HASSERVICECHARGES",
    }.freeze

    UPRN_CONFIRMED_LABELS = {
      0 => "No",
      1 => "Yes",
    }.freeze

    LABELS = {
      "uprn_confirmed" => UPRN_CONFIRMED_LABELS,
    }.freeze

    ATTRIBUTE_MAPPINGS = {
      "saledate" => %w[day month year],
      "exdate" => %w[exday exmonth exyear],
      "hodate" => %w[hoday homonth hoyear],
      "ppostcode_full" => %w[ppostc1 ppostc2],
      "la" => %w[la la_label],
      "prevloc" => %w[prevloc prevloc_label],
      "assigned_to_id" => %w[created_by assigned_to],
      "owning_organisation_id" => %w[owning_organisation_name],
      "managing_organisation_id" => %w[managing_organisation_name],
      "value" => %w[value value_value_check],
      "mscharge" => %w[mscharge mscharge_value_check],
    }.freeze

    ATTRIBUTE_MAPPINGS_2024 = {
      "uprn" => %w[uprn uprn_confirmed address_line1_input postcode_full_input uprn_selection],
    }.freeze

    ATTRIBUTE_MAPPINGS_2025 = {
      "duplicate_set_id" => %w[duplicate_set_id owning_organisation_name owning_organisation_id managing_organisation_name managing_organisation_id],
      "created_by_id" => %w[created_by created_by_id assigned_to assigned_to_id],
      "updated_by_id" => %w[updated_by updated_by_id],
      "bulk_upload_id" => %w[bulk_upload_id collection_start_year],
      "prevten" => %w[hhtype prevten],
      "mrent" => %w[mrent has_servicecharges servicecharges has_management_fee management_fee],
      "lasttransaction" => %w[stairlastday stairlastmonth stairlastyear],
      "initialpurchase" => %w[stairinitialday stairinitialmonth stairinitialyear],
      "mrentprestaircasing" => %w[mrentprestaircasing grant discount extrabor has_mscharge mscharge mscharge_value_check],
    }.freeze

    def formatted_attribute_headers
      return @attributes unless @user.support?

      mappings = SUPPORT_ATTRIBUTE_NAME_MAPPINGS
      mappings = mappings.merge(SUPPORT_ATTRIBUTE_NAME_MAPPINGS_2025) if @year == 2025

      @attributes.map do |attribute|
        mappings[attribute] || attribute.upcase
      end
    end

    def sales_log_attributes
      ordered_questions = FormHandler.instance.ordered_questions_for_year(@year, "sales")
      ordered_questions.reject! { |q| q.id.match?(/((?<!la)_known)|(_check)|(_asked)|nationality_all_group|nationality_all_buyer2_group/) }
      ordered_questions.reject! { |q| q.id.match?(/organisation_id|created_by|assigned_to|soctenant|has_management_fee|management_fee|grant|discount|has_mscharge|mscharge|extrabor/) } if @year >= 2025
      order_saledate_question_before_owning_organisation_question(ordered_questions)
      attributes = insert_checkbox_options(ordered_questions)
      final_attributes = insert_derived_and_related_attributes(non_question_fields + attributes)
      order_address_fields_for_support(final_attributes)
      @user.support? ? final_attributes : final_attributes - SUPPORT_ONLY_ATTRIBUTES
    end

    def sales_log_definitions
      CsvVariableDefinition.sales.group_by(&:variable).map { |_, options|
        exact_match = options.find { |definition| definition.year == @year }
        next exact_match if exact_match

        options.select { |opt| opt.year < @year }.max_by(&:year)
      }.compact
    end

    def insert_checkbox_options(ordered_questions)
      ordered_questions.flat_map do |question|
        if question.type == "checkbox"
          question.answer_options.keys
        else
          question.id
        end
      end
    end

    def insert_derived_and_related_attributes(attributes)
      attributes.flat_map do |attribute|
        if attribute_mappings.key? attribute
          attribute_mappings[attribute]
        else
          attribute
        end
      end
    end

    def attribute_mappings
      mappings = case @year
                 when 2024
                   ATTRIBUTE_MAPPINGS.merge(ATTRIBUTE_MAPPINGS_2024)
                 when 2025
                   ATTRIBUTE_MAPPINGS.merge(ATTRIBUTE_MAPPINGS_2024).merge(ATTRIBUTE_MAPPINGS_2025)
                 else
                   ATTRIBUTE_MAPPINGS
                 end

      unless @user.support? && @year >= 2024
        mappings = mappings.merge({ "postcode_full" => %w[pcode1 pcode2] })
      end

      mappings
    end

    def order_address_fields_for_support(attributes)
      if @user.support? && @year >= 2024
        first_address_field_index = attributes.find_index { |q| all_address_fields.include?(q) }
        if first_address_field_index
          attributes.reject! { |q| all_address_fields.include?(q) }
          attributes.insert(first_address_field_index, *ORDERED_ADDRESS_FIELDS)
        end
      end
    end

    # as part of CLDC-3719 it was decided to move the saledate question to be first in the form
    # this caused issues reported in CLDC-4025 where the user only enter saledates for their active organisation
    # we decided to move the organisation question back to being first
    # however, we did not want to reorder the CSV export as this would disrupt existing users' data pipelines
    # so, this function reorders questions back when exporting CSVs
    # next year, we can remove this function as we will be reordering the csv fields anyway
    def order_saledate_question_before_owning_organisation_question(ordered_questions)
      saledate_question_index = ordered_questions.find_index { |q| q.id == "saledate" }
      owning_organisation_index = ordered_questions.find_index { |q| q.id == "owning_organisation_id" }
      if saledate_question_index && owning_organisation_index
        saledate_question = ordered_questions.delete_at(saledate_question_index)
        ordered_questions.insert(owning_organisation_index, saledate_question)
      end
    end

    def non_question_fields
      case @year
      when 2022
        %w[id status created_at updated_at old_form_id collection_start_year creation_method is_dpo]
      when 2023
        %w[id status duplicate_set_id created_at updated_at old_form_id collection_start_year creation_method is_dpo]
      when 2024
        %w[id status duplicate_set_id created_at updated_at collection_start_year creation_method bulk_upload_id is_dpo]
      when 2025
        %w[id status duplicate_set_id created_at created_by_id updated_at updated_by_id creation_method bulk_upload_id]
      else
        %w[id status duplicate_set_id created_at updated_at collection_start_year creation_method bulk_upload_id is_dpo]
      end
    end

    def all_address_fields
      ORDERED_ADDRESS_FIELDS + %w[uprn_confirmed]
    end

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
      elsif PERSON_DETAILS.key?(attribute) && (person_details_not_known?(log, attribute) || age_not_known?(log, attribute))
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

    def person_details_not_known?(log, attribute)
      details_known_field = PERSON_DETAILS.find { |key, _value| key == attribute }[1]["details_known_field"]
      log[details_known_field] == 2 # 1 for lettings logs, 2 for sales logs
    end

    def age_not_known?(log, attribute)
      age_known_field = PERSON_DETAILS.find { |key, _value| key == attribute }[1]["age_known_field"]
      log[age_known_field] == 1
    end

    def get_label(value, attribute, log)
      return LABELS[attribute][value] if LABELS.key?(attribute)

      log.form
         .get_question(attribute, log)
         &.label_from_value(value)
    end

    def label_if_boolean_value(value)
      return "Yes" if value == true
      return "No" if value == false
    end
  end
end
