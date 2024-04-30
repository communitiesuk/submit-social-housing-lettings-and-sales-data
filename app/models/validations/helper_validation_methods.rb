module Validations::HelperValidationMethods
  def active_collection_start_date
    if FormHandler.instance.lettings_in_crossover_period?
      previous_collection_start_date
    else
      current_collection_start_date
    end
  end

  def editable_collection_start_date
    if FormHandler.instance.lettings_in_edit_crossover_period?
      previous_collection_start_date
    else
      current_collection_start_date
    end
  end

  def startdate_validation_error_message
    current_end_year_long = current_collection_end_date.strftime("#{current_collection_end_date.day.ordinalize} %B %Y")

    if FormHandler.instance.lettings_in_crossover_period?
      I18n.t(
        "validations.setup.startdate.previous_and_current_collection_year",
        previous_start_year_short: previous_collection_start_date.strftime("%y"),
        previous_end_year_short: previous_collection_end_date.strftime("%y"),
        previous_start_year_long: previous_collection_start_date.strftime("#{previous_collection_start_date.day.ordinalize} %B %Y"),
        current_end_year_short: current_collection_end_date.strftime("%y"),
        current_end_year_long:,
      )
    else
      I18n.t(
        "validations.setup.startdate.current_collection_year",
        current_start_year_short: current_collection_start_date.strftime("%y"),
        current_end_year_short: current_collection_end_date.strftime("%y"),
        current_start_year_long: current_collection_start_date.strftime("#{current_collection_start_date.day.ordinalize} %B %Y"),
        current_end_year_long:,
      )
    end
  end

  def intermediate_product_rent_type?(record)
    record.rent_type == 5
  end

  def add_same_merge_organisation_error(record)
    if merged_owning_organisation_inactive?(record)
      record.errors.add :startdate, I18n.t("validations.setup.startdate.invalid_merged_organisations_start_date.same_organisation",
                                          owning_organisation: record.owning_organisation.name,
                                          owning_organisation_merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                          owning_absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
    elsif absorbing_owning_organisation_inactive?(record)
      record.errors.add :startdate, I18n.t("validations.setup.startdate.invalid_absorbing_organisations_start_date.same_organisation",
                                          owning_organisation: record.owning_organisation.name,
                                          owning_organisation_available_from: record.owning_organisation.available_from.to_formatted_s(:govuk_date))
    end
  end

  def add_same_merge_error(record)
    if merged_owning_organisation_inactive?(record)
      record.errors.add :startdate, I18n.t("validations.setup.startdate.invalid_merged_organisations_start_date.same_merge",
                                          owning_organisation: record.owning_organisation.name,
                                          managing_organisation: record.managing_organisation.name,
                                          owning_organisation_merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                          owning_absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
    end
  end

  def add_merged_organisations_errors(record)
    if merged_owning_organisation_inactive?(record) && merged_managing_organisation_inactive?(record)
      record.errors.add :startdate, I18n.t("validations.setup.startdate.invalid_merged_organisations_start_date.different_merge",
                                          owning_organisation: record.owning_organisation.name,
                                          owning_organisation_merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                          owning_absorbing_organisation: record.owning_organisation.absorbing_organisation.name,
                                          managing_organisation: record.managing_organisation.name,
                                          managing_organisation_merge_date: record.managing_organisation.merge_date.to_formatted_s(:govuk_date),
                                          managing_absorbing_organisation: record.managing_organisation.absorbing_organisation.name)
    else
      if merged_owning_organisation_inactive?(record)
        record.errors.add :startdate, I18n.t("validations.setup.startdate.invalid_merged_organisations_start_date.owning_organisation",
                                            owning_organisation: record.owning_organisation.name,
                                            owning_organisation_merge_date: record.owning_organisation.merge_date.to_formatted_s(:govuk_date),
                                            owning_absorbing_organisation: record.owning_organisation.absorbing_organisation.name)
      end

      if merged_managing_organisation_inactive?(record)
        record.errors.add :startdate, I18n.t("validations.setup.startdate.invalid_merged_organisations_start_date.managing_organisation",
                                            managing_organisation: record.managing_organisation.name,
                                            managing_organisation_merge_date: record.managing_organisation.merge_date.to_formatted_s(:govuk_date),
                                            managing_absorbing_organisation: record.managing_organisation.absorbing_organisation.name)
      end
    end
  end

  def add_absorbing_organisations_errors(record)
    if absorbing_owning_organisation_inactive?(record) && absorbing_managing_organisation_inactive?(record)
      record.errors.add :startdate, I18n.t("validations.setup.startdate.invalid_absorbing_organisations_start_date.different_organisations",
                                          owning_organisation: record.owning_organisation.name,
                                          owning_organisation_active_from: record.owning_organisation.available_from.to_formatted_s(:govuk_date),
                                          managing_organisation: record.managing_organisation.name,
                                          managing_organisation_active_from: record.managing_organisation.available_from.to_formatted_s(:govuk_date))
    else
      if absorbing_owning_organisation_inactive?(record)
        record.errors.add :startdate, I18n.t("validations.setup.startdate.invalid_absorbing_organisations_start_date.owning_organisation",
                                            owning_organisation: record.owning_organisation.name,
                                            owning_organisation_available_from: record.owning_organisation.available_from.to_formatted_s(:govuk_date))
      end

      if absorbing_managing_organisation_inactive?(record)
        record.errors.add :startdate, I18n.t("validations.setup.startdate.invalid_absorbing_organisations_start_date.managing_organisation",
                                            managing_organisation: record.managing_organisation.name,
                                            managing_organisation_available_from: record.managing_organisation.available_from.to_formatted_s(:govuk_date))
      end
    end
  end

  def merged_owning_organisation_inactive?(record)
    record.owning_organisation&.merge_date.present? && record.owning_organisation.merge_date <= record.startdate
  end

  def merged_managing_organisation_inactive?(record)
    record.managing_organisation&.merge_date.present? && record.managing_organisation.merge_date <= record.startdate
  end

  def absorbing_owning_organisation_inactive?(record)
    record.owning_organisation&.absorbed_organisations.present? && record.owning_organisation.available_from.present? && record.owning_organisation.available_from.to_date > record.startdate.to_date
  end

  def absorbing_managing_organisation_inactive?(record)
    record.managing_organisation&.absorbed_organisations.present? && record.managing_organisation.available_from.present? && record.managing_organisation.available_from.to_date > record.startdate.to_date
  end

  def organisations_belong_to_same_merge?(organisation_a, organisation_b)
    organisation_a&.merge_date.present? && organisation_b&.merge_date.present? && organisation_a.merge_date == organisation_b.merge_date && organisation_a.absorbing_organisation == organisation_b.absorbing_organisation
  end

  def person_is_partner?(relationship)
    relationship == "P"
  end

  def add_range_error(record, question)
    field = question.check_answer_label || question.id
    min = [question.prefix, number_with_delimiter(question.min, delimiter: ","), question.suffix].join("") if question.min
    max = [question.prefix, number_with_delimiter(question.max, delimiter: ","), question.suffix].join("") if question.max

    if min && max
      record.errors.add question.id.to_sym, :outside_the_range, message: I18n.t("validations.numeric.within_range", field:, min:, max:)
    elsif min
      record.errors.add question.id.to_sym, :under_min, message: I18n.t("validations.numeric.above_min", field:, min:)
    end
  end



  def household_no_illness?(record)
    record.illness != 1
  end

  def women_of_child_bearing_age_in_household(record)
    (1..8).any? do |n|
      next if record["sex#{n}"].nil?

      record["sex#{n}"] == "F" && (in_pregnancy_age_range?(record, n) || record.age_unknown?(n))
    end
  end

  def in_pregnancy_age_range?(record, person_num)
    return false if record["age#{person_num}"].nil?

    record["age#{person_num}"] >= 11 && record["age#{person_num}"] <= 65
  end

  def women_in_household(record)
    (1..8).any? do |n|
      record["sex#{n}"] == "F"
    end
  end

  def tenant_is_economic_child?(economic_status)
    economic_status == 9
  end

  def tenant_is_fulltime_student?(economic_status)
    economic_status == 7
  end

  def tenant_economic_status_refused?(economic_status)
    economic_status == 10
  end

  def economic_status_is_child_other_or_refused?(economic_status)
    [9, 0, 10].include?(economic_status)
  end

  def tenant_is_child?(relationship)
    relationship == "C"
  end

  def relationship_is_child_other_or_refused?(relationship)
    %w[C X R].include?(relationship)
  end

  def validate_charges(record)
    return unless record.owning_organisation

    provider_type = record.owning_organisation.provider_type_before_type_cast
    %i[scharge pscharge supcharg].each do |charge|
      maximum_per_week = CHARGE_MAXIMA_PER_WEEK.dig(charge, PROVIDER_TYPE[provider_type], NEEDSTYPE_VALUES[record.needstype])

      next unless maximum_per_week.present? && record[:period].present? && record[charge].present? && !weekly_value_in_range(record, charge, 0.0, maximum_per_week)

      charge_name = CHARGE_NAMES[charge]
      frequency = record.form.get_question("period", record).label_from_value(record.period).downcase
      letting_type = NEEDSTYPE_VALUES[record.needstype].to_s.humanize(capitalize: false)
      provider_type_label = PROVIDER_TYPE[provider_type].to_s.humanize(capitalize: false)
      maximum_per_period = record.weekly_to_value_per_period(maximum_per_week)

      record.errors.add charge, :outside_the_range, message: I18n.t("validations.financial.rent.out_of_range", charge_name:, maximum_per_period:, frequency:, letting_type:, provider_type: provider_type_label)
      record.errors.add :period, :outside_the_range, message: I18n.t("validations.financial.rent.out_of_range", charge_name:, maximum_per_period:, frequency:, letting_type:, provider_type: provider_type_label)
    end
  end

  def weekly_value_in_range(record, field, min, max)
    record.weekly_value(record[field])&.between?(min, max)
  end

  def validate_rent_range(record)
    return if record.startdate.blank?

    collection_year = record.collection_start_year

    rent_range = LaRentRange.find_by(
      start_year: collection_year,
      la: record.la,
      beds: record.beds_for_la_rent_range,
      lettype: record.lettype,
    )

    if rent_range.present? && !weekly_value_in_range(record, "brent", rent_range.hard_min, rent_range.hard_max) && record.brent.present? && record.period.present?
      if record.weekly_value(record["brent"]) < rent_range.hard_min
        record.errors.add :brent, :below_hard_min, message: I18n.t("validations.financial.brent.below_hard_min")
        record.errors.add :beds, I18n.t("validations.financial.brent.beds.below_hard_min")
        record.errors.add :uprn, I18n.t("validations.financial.brent.uprn.below_hard_min")
        record.errors.add :la, I18n.t("validations.financial.brent.la.below_hard_min")
        record.errors.add :postcode_known, I18n.t("validations.financial.brent.postcode_known.below_hard_min")
        record.errors.add :scheme_id, I18n.t("validations.financial.brent.scheme_id.below_hard_min")
        record.errors.add :location_id, I18n.t("validations.financial.brent.location_id.below_hard_min")
        record.errors.add :rent_type, I18n.t("validations.financial.brent.rent_type.below_hard_min")
        record.errors.add :needstype, I18n.t("validations.financial.brent.needstype.below_hard_min")
        record.errors.add :period, I18n.t("validations.financial.brent.period.below_hard_min")
      end

      if record.weekly_value(record["brent"]) > rent_range.hard_max
        record.errors.add :brent, :over_hard_max, message: I18n.t("validations.financial.brent.above_hard_max")
        record.errors.add :beds, I18n.t("validations.financial.brent.beds.above_hard_max")
        record.errors.add :uprn, I18n.t("validations.financial.brent.uprn.above_hard_max")
        record.errors.add :la, I18n.t("validations.financial.brent.la.above_hard_max")
        record.errors.add :postcode_known, I18n.t("validations.financial.brent.postcode_known.above_hard_max")
        record.errors.add :scheme_id, I18n.t("validations.financial.brent.scheme_id.above_hard_max")
        record.errors.add :location_id, I18n.t("validations.financial.brent.location_id.above_hard_max")
        record.errors.add :rent_type, I18n.t("validations.financial.brent.rent_type.above_hard_max")
        record.errors.add :needstype, I18n.t("validations.financial.brent.needstype.above_hard_max")
        record.errors.add :period, I18n.t("validations.financial.brent.period.above_hard_max")
      end
    end
  end

  def is_rsnvac_first_let?(record)
    [15, 16, 17].include?(record["rsnvac"])
  end
end