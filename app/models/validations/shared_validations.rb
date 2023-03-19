module Validations::SharedValidations
  include ActionView::Helpers::NumberHelper

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
      next unless record[question.id] && question.page.routed_to?(record, nil)

      begin
        answer = Float(record.public_send("#{question.id}_before_type_cast"))
      rescue ArgumentError
        add_range_error(record, question)
      end

      next unless answer

      if (question.min && question.min > answer) || (question.max && question.max < answer)
        add_range_error(record, question)
      end
    end
  end

  def validate_numeric_step(record)
    record.form.numeric_questions.each do |question|
      next unless question.step
      next unless record[question.id] && question.page.routed_to?(record, nil)

      begin
        input = record.public_send("#{question.id}_before_type_cast")
        answer = Float(input)
      rescue ArgumentError
        add_step_error(record, question)
      end

      if (answer * 100) % (question.step * 100) != 0
        add_step_error(record, question)
      end
    end
  end

  def validate_numeric_normal_format(record)
    record.form.numeric_questions.each do |question|
      next unless record[question.id] && question.page.routed_to?(record, nil)

      user_input = record.public_send("#{question.id}_before_type_cast")
      if user_input.is_a?(String) && user_input.include?("e")
        record.errors.add question.id.to_sym, I18n.t("validations.numeric.normal_format")
      end
  end
  end

  def validate_property_postcode(record)
    postcode = record.postcode_full
    if record.postcode_known? && (postcode.blank? || !postcode.match(POSTCODE_REGEXP))
      error_message = I18n.t("validations.postcode")
      record.errors.add :postcode_full, :wrong_format, message: error_message
    end
  end

  def location_during_startdate_validation(record, field)
    location_inactive_status = inactive_status(record.startdate, record.location)

    if location_inactive_status.present?
      date, scope, deactivation_date = location_inactive_status.values_at(:date, :scope, :deactivation_date)
      record.errors.add field, :not_active, message: I18n.t("validations.setup.startdate.location.#{scope}", postcode: record.location.postcode, date:, deactivation_date:)
    end
  end

  def scheme_during_startdate_validation(record, field)
    scheme_inactive_status = inactive_status(record.startdate, record.scheme)
    if scheme_inactive_status.present?
      date, scope, deactivation_date = scheme_inactive_status.values_at(:date, :scope, :deactivation_date)
      record.errors.add field, I18n.t("validations.setup.startdate.scheme.#{scope}", name: record.scheme.service_name, date:, deactivation_date:)
    end
  end

  def inactive_status(date, resource)
    return if date.blank? || resource.blank?

    status = resource.status_at(date)
    return unless %i[reactivating_soon activating_soon deactivated].include?(status)

    closest_reactivation = resource.recent_deactivation
    open_deactivation = resource.open_deactivation

    date = case status
           when :reactivating_soon then closest_reactivation.reactivation_date
           when :activating_soon then resource&.available_from
           when :deactivated then open_deactivation.deactivation_date
           end

    { scope: status, date: date&.to_formatted_s(:govuk_date), deactivation_date: closest_reactivation&.deactivation_date&.to_formatted_s(:govuk_date) }
  end

  def shared_validate_partner_count(record, max_people)
    partner_numbers = (2..max_people).select { |n| person_is_partner?(record["relat#{n}"]) }
    if partner_numbers.count > 1
      partner_numbers.each do |n|
        record.errors.add "relat#{n}", I18n.t("validations.household.relat.one_partner")
      end
    end
  end

  def date_valid?(question, record)
    if record[question].is_a?(ActiveSupport::TimeWithZone) && record[question].year.zero?
      record.errors.add question, I18n.t("validations.date.invalid_date")
      false
    else
      true
    end
  end

private

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

  def add_step_error(record, question)
    field = question.check_answer_label || question.id
    case question.step
    when 1 then record.errors.add question.id.to_sym, I18n.t("validations.numeric.whole_number", field:)
    when 10 then record.errors.add question.id.to_sym, I18n.t("validations.numeric.nearest_ten", field:)
    when 0.01 then record.errors.add question.id.to_sym, I18n.t("validations.numeric.nearest_penny", field:)
    end
  end
end
