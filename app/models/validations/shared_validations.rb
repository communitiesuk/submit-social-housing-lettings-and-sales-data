module Validations::SharedValidations
  include ActionView::Helpers::NumberHelper

  def validate_other_field(record, value_other = nil, main_field = nil, other_field = nil, main_label = nil, other_label = nil)
    return unless main_field || other_field

    main_field_label = main_label || main_field.to_s.humanize(capitalize: false)
    other_field_label = other_label || other_field.to_s.humanize(capitalize: false)
    if record[main_field] == value_other && record[other_field].blank?
      record.errors.add main_field.to_sym, I18n.t("validations.shared.other_field_missing", main_field_label:, other_field_label:)
      record.errors.add other_field.to_sym, I18n.t("validations.shared.other_field_missing", main_field_label:, other_field_label:)
    end

    if record[main_field] != value_other && record[other_field].present?
      record.errors.add other_field.to_sym, I18n.t("validations.shared.other_field_not_required", main_field_label:, other_field_label:)
    end
  end

  def validate_numeric_input(record)
    record.form.numeric_questions.each do |question|
      next unless record[question.id] && question.page.routed_to?(record, nil)
      next if record.send("#{question.id}_before_type_cast").to_s.match?(/\A\d+(\.\d+)?\z/)

      field = question.check_answer_label || question.id
      record.errors.add question.id.to_sym, I18n.t("validations.shared.numeric.format", field:)
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

      value = record.public_send("#{question.id}_before_type_cast")
      field = question.check_answer_label || question.id
      incorrect_accuracy = (value.to_d * 100) % (question.step * 100) != 0

      next unless incorrect_accuracy

      case question.step
      when 0.01 then record.errors.add question.id.to_sym, I18n.t("validations.shared.numeric.nearest_hundredth", field:)
      when 0.1 then record.errors.add question.id.to_sym, I18n.t("validations.shared.numeric.nearest_tenth", field:)
      when 1 then record.errors.add question.id.to_sym, :not_integer, message: I18n.t("validations.shared.numeric.whole_number", field:)
      when 10 then record.errors.add question.id.to_sym, I18n.t("validations.shared.numeric.nearest_ten", field:)
      else
        record.errors.add question.id.to_sym, I18n.t("validations.shared.numeric.nearest_step", field:, step: question.step)
      end
    end
  end

  def inactive_status(date, resource)
    return if date.blank? || resource.blank?

    status = resource.status_at(date)
    return unless %i[reactivating_soon activating_soon deactivated].include?(status)

    closest_reactivation = resource.soonest_reactivation(date)
    open_deactivation = if resource.is_a?(Location)
                          resource.open_deactivation || resource.scheme.open_deactivation
                        else
                          resource.open_deactivation
                        end

    date = case status
           when :reactivating_soon then closest_reactivation.reactivation_date
           when :activating_soon then resource&.available_from
           when :deactivated then open_deactivation.deactivation_date
           end

    { scope: status, date: date&.to_formatted_s(:govuk_date) }
  end

  def date_valid?(question, record)
    if record[question].is_a?(ActiveSupport::TimeWithZone) && record[question].year.zero?
      record.errors.add question, I18n.t("validations.shared.date.invalid_date")
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
      record.errors.add question.id.to_sym, :outside_the_range, message: I18n.t("validations.shared.numeric.within_range", field:, min:, max:)
    elsif min
      record.errors.add question.id.to_sym, :under_min, message: I18n.t("validations.shared.numeric.above_min", field:, min:)
    end
  end
end
