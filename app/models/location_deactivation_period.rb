class LocationDeactivationPeriodValidator < ActiveModel::Validator
  def validate(record)
    location = record.location

    if record.deactivation_date.blank?
      if record.deactivation_date_type.blank?
        record.errors.add(:deactivation_date_type, message: I18n.t("validations.location.toggle_date.not_selected"))
      elsif record.deactivation_date_type == "other"
        record.errors.add(:deactivation_date, message: I18n.t("validations.location.toggle_date.invalid"))
      end
    elsif location.location_deactivation_periods.any? { |period| period.reactivation_date.present? && record.deactivation_date.between?(period.deactivation_date, period.reactivation_date - 1.day) }
      record.errors.add(:deactivation_date, message: I18n.t("validations.location.deactivation.during_deactivated_period"))
    else
      unless record.deactivation_date.between?(location.available_from, Time.zone.local(2200, 1, 1))
        record.errors.add(:deactivation_date, message: I18n.t("validations.location.toggle_date.out_of_range", date: location.available_from.to_formatted_s(:govuk_date)))
      end
    end

    recent_deactivation = location.location_deactivation_periods.deactivations_without_reactivation.first
    if recent_deactivation
      if record.reactivation_date.blank?
        if record.reactivation_date_type.blank?
          record.errors.add(:reactivation_date_type, message: I18n.t("validations.location.toggle_date.not_selected"))
        elsif record.reactivation_date_type == "other"
          record.errors.add(:reactivation_date, message: I18n.t("validations.location.toggle_date.invalid"))
        end
      elsif !record.reactivation_date.between?(location.available_from, Time.zone.local(2200, 1, 1))
        record.errors.add(:reactivation_date, message: I18n.t("validations.location.toggle_date.out_of_range", date: location.available_from.to_formatted_s(:govuk_date)))
      elsif record.reactivation_date < recent_deactivation.deactivation_date
        record.errors.add(:reactivation_date, message: I18n.t("validations.location.reactivation.before_deactivation", date: recent_deactivation.deactivation_date.to_formatted_s(:govuk_date)))
      end
    end
  end
end

class LocationDeactivationPeriod < ApplicationRecord
  validates_with LocationDeactivationPeriodValidator
  belongs_to :location
  attr_accessor :deactivation_date_type, :reactivation_date_type

  scope :deactivations_without_reactivation, -> { where(reactivation_date: nil) }
end
