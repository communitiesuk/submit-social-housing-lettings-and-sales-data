module Validations::DateValidations
  include Validations::SharedValidations

  def validate_property_major_repairs(record)
    date_valid?("mrcdate", record)
    if record["startdate"].present? && record["mrcdate"].present? && record["startdate"] < record["mrcdate"]
      record.errors.add :mrcdate, I18n.t("validations.lettings.date.mrcdate.before_tenancy_start")
    end

    if is_rsnvac_first_let?(record) && record["mrcdate"].present?
      record.errors.add :mrcdate, I18n.t("validations.lettings.date.mrcdate.not_first_let")
    end

    return unless record["mrcdate"].present? && record["startdate"].present?

    if record.form.start_year_2025_or_later?
      if record["startdate"].to_date - record["mrcdate"].to_date > 7300
        record.errors.add :mrcdate, I18n.t("validations.lettings.date.mrcdate.twenty_years_before_tenancy_start")
      end
    elsif record["startdate"].to_date - record["mrcdate"].to_date > 3650
      record.errors.add :mrcdate, I18n.t("validations.lettings.date.mrcdate.ten_years_before_tenancy_start")
    end
  end

  def validate_property_void_date(record)
    if record["voiddate"].present? && record["startdate"].present?
      if record.form.start_year_2025_or_later?
        if record["startdate"].to_date - record["voiddate"].to_date > 7300
          record.errors.add :voiddate, I18n.t("validations.lettings.date.void_date.twenty_years_before_tenancy_start")
        end
      elsif record["startdate"].to_date - record["voiddate"].to_date > 3650
        record.errors.add :voiddate, I18n.t("validations.lettings.date.void_date.ten_years_before_tenancy_start")
      end
    end

    if record["voiddate"].present? && record["startdate"].present? && record["startdate"].to_date < record["voiddate"].to_date
      record.errors.add :voiddate, I18n.t("validations.lettings.date.void_date.before_tenancy_start")
    end

    if record["voiddate"].present? && record["mrcdate"].present? && record["mrcdate"].to_date < record["voiddate"].to_date
      record.errors.add :voiddate, :after_mrcdate, message: I18n.t("validations.lettings.date.void_date.after_mrcdate")
      record.errors.add :mrcdate, I18n.t("validations.lettings.date.mrcdate.before_void_date")
    end
  end

  def validate_startdate(record)
    return unless record.startdate && date_valid?("startdate", record)

    if record["voiddate"].present? && record.startdate < record["voiddate"]
      record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.after_void_date")
    end

    if record["mrcdate"].present? && record.startdate < record["mrcdate"]
      record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.after_major_repair_date")
    end

    validate_startdate_against_mrc_and_void_dates(record)
  end

private

  def is_rsnvac_first_let?(record)
    [15, 16, 17].include?(record["rsnvac"])
  end

  def validate_startdate_against_mrc_and_void_dates(record)
    if record.form.start_year_2025_or_later?
      if record["voiddate"].present? && record["startdate"].to_date - record["voiddate"].to_date > 7300
        record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.twenty_years_after_void_date")
      end

      if record["mrcdate"].present? && record["startdate"].to_date - record["mrcdate"].to_date > 7300
        record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.twenty_years_after_mrc_date")
      end
    else
      if record["voiddate"].present? && record["startdate"].to_date - record["voiddate"].to_date > 3650
        record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.ten_years_after_void_date")
      end

      if record["mrcdate"].present? && record["startdate"].to_date - record["mrcdate"].to_date > 3650
        record.errors.add :startdate, I18n.t("validations.lettings.date.startdate.ten_years_after_mrc_date")
      end
    end
  end
end
