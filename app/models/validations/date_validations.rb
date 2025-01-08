module Validations::DateValidations
  include Validations::SharedValidations

  def validate_property_major_repairs(record)
    return unless record["mrcdate"].present? && date_valid?("mrcdate", record)

    if is_rsnvac_first_let?(record) && record["mrcdate"].present?
      record.errors.add :mrcdate, I18n.t("validations.lettings.date.mrcdate.not_first_let")
    end
    return unless record["startdate"].present? && date_valid?("startdate", record)

    if record["startdate"].present? && record["mrcdate"].present? && record["startdate"] < record["mrcdate"]
      record.errors.add :mrcdate, I18n.t("validations.lettings.date.mrcdate.before_tenancy_start")
      record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.after_major_repair_date")
    end

    if record.form.start_year_2025_or_later?
      if record["startdate"].to_date - 20.years > record["mrcdate"].to_date
        record.errors.add :mrcdate, I18n.t("validations.lettings.date.mrcdate.twenty_years_before_tenancy_start")
        record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.twenty_years_after_mrc_date")
      end
    elsif record["startdate"].to_date - 10.years > record["mrcdate"].to_date
      record.errors.add :mrcdate, I18n.t("validations.lettings.date.mrcdate.ten_years_before_tenancy_start")
      record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.ten_years_after_mrc_date")
    end
  end

  def validate_property_void_date(record)
    return unless record["voiddate"].present? && date_valid?("voiddate", record)

    if record["mrcdate"].present? && record["mrcdate"].to_date < record["voiddate"].to_date
      record.errors.add :voiddate, :after_mrcdate, message: I18n.t("validations.lettings.date.void_date.after_mrcdate")
      record.errors.add :mrcdate, I18n.t("validations.lettings.date.mrcdate.before_void_date")
    end
    return unless record["startdate"].present? && date_valid?("startdate", record)

    if record["startdate"].to_date < record["voiddate"].to_date
      record.errors.add :voiddate, I18n.t("validations.lettings.date.void_date.before_tenancy_start")
      record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.after_void_date")
    end

    if record.form.start_year_2025_or_later?
      if record["startdate"].to_date - 20.years > record["voiddate"].to_date
        record.errors.add :voiddate, I18n.t("validations.lettings.date.void_date.twenty_years_before_tenancy_start")
        record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.twenty_years_after_void_date")
      end
    elsif record["startdate"].to_date - 10.years > record["voiddate"].to_date
      record.errors.add :voiddate, I18n.t("validations.lettings.date.void_date.ten_years_before_tenancy_start")
      record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.ten_years_after_void_date")
    end
  end

  def validate_startdate(record)
    date_valid?("startdate", record)
  end

private

  def is_rsnvac_first_let?(record)
    [15, 16, 17].include?(record["rsnvac"])
  end
end
