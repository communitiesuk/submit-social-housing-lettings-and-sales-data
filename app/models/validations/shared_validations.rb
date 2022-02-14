module Validations::SharedValidations
  def validate_other_field(record, main_field = nil, other_field = nil)
    return unless main_field || other_field

    main_field_label = main_field.to_s.humanize(capitalize: false)
    other_field_label = other_field.to_s.humanize(capitalize: false)
    if record[main_field] == "Other" && record[other_field].blank?
      record.errors.add other_field.to_sym, I18n.t("validations.other_field_missing", main_field_label:, other_field_label:)
    end

    if record[main_field] != "Other" && record[other_field].present?
      record.errors.add other_field.to_sym, I18n.t("validations.other_field_not_required", main_field_label:, other_field_label:)
    end
  end
end
