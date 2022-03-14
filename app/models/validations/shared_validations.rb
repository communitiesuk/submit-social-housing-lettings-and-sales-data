module Validations::SharedValidations
  def validate_other_field(record, value_other = nil, main_field = nil, other_field = nil)
    return unless main_field || other_field

    main_field_label = main_field.to_s.humanize(capitalize: false)
    other_field_label = other_field.to_s.humanize(capitalize: false)
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
end
