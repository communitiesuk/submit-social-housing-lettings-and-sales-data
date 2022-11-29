module Validations::SharedValidations
  def validate_other_field(record, value_other = nil, main_field = nil, other_field = nil, main_label = nil, other_label = nil)
    return unless main_field || other_field

    main_field_label = main_label || main_field.to_s.humanize(capitalize: false)
    other_field_label = other_label || other_field.to_s.humanize(capitalize: false)
    if record[main_field] == value_other && record[other_field].blank?
      record.errors.add other_field.to_sym, I18n.t("validations.other_field_missing", main_field_label:, other_field_label:)
    end

    if record[main_field] != value_other && record[other_field].present?
      record.errors.add other_field.to_sym, I18n.t("validations.other_field_not_required", main_field_label:, other_field_label:)
    end
  end

  def validate_numeric_min_max(record)
    record.form.numeric_questions.each do |question|
      next unless question.min || question.max
      next unless record[question.id]

      field = question.check_answer_label || question.id

      begin
        answer = Float(record.public_send("#{question.id}_before_type_cast"))
      rescue ArgumentError
        record.errors.add question.id.to_sym, I18n.t("validations.numeric.valid", field:, min: question.min, max: question.max)
      end

      next unless answer

      if (question.min && question.min > answer) || (question.max && question.max < answer)
        record.errors.add question.id.to_sym, I18n.t("validations.numeric.valid", field:, min: question.min, max: question.max)
      end
    end
  end

  def location_during_startdate_validation(record, field)
    location_inactive_status = inactive_status(record.startdate, record.location&.available_from, record.location)
    if location_inactive_status.present?
      record.errors.add field, I18n.t("validations.setup.startdate.location_#{location_inactive_status[:status]}", postcode: record.location.postcode, date: location_inactive_status[:reactivation_date].to_formatted_s(:govuk_date), deactivation_date: location_inactive_status[:deactivation_date]&.to_formatted_s(:govuk_date))
    end
  end

  def scheme_during_startdate_validation(record, field)
    scheme_inactive_status = inactive_status(record.startdate, record.scheme&.available_from, record.scheme)
    if scheme_inactive_status.present?
      record.errors.add field, I18n.t("validations.setup.startdate.scheme_#{scheme_inactive_status[:status]}", name: record.scheme.service_name, date: scheme_inactive_status[:reactivation_date].to_formatted_s(:govuk_date), deactivation_date: scheme_inactive_status[:deactivation_date]&.to_formatted_s(:govuk_date))
    end
  end

  def inactive_status(date, available_from, resource)
    return if date.blank? || resource.blank?

    status = resource.status(date)
    return unless %i[reactivating_soon activating_soon deactivated].include?(status)

    closest_reactivation = resource.recent_deactivation
    open_deactivation = resource.open_deactivation

    case status
    when :reactivating_soon
      reactivation_date = closest_reactivation.reactivation_date
      deactivation_date = closest_reactivation.deactivation_date
    when :activating_soon
      reactivation_date = available_from
    when :deactivated
      reactivation_date = open_deactivation.deactivation_date
    end

    { status:, reactivation_date:, deactivation_date: }
  end
end
