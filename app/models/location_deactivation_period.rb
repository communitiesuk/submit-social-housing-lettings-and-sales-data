class LocationDeactivationPeriodValidator < ActiveModel::Validator
  include CollectionTimeHelper

  def validate(record)
    location = record.location
    open_deactivation = location.location_deactivation_periods.deactivations_without_reactivation.first
    if open_deactivation.present? && open_deactivation.deactivation_date <= 6.months.from_now
      validate_reactivation(record, open_deactivation, location)
    else
      validate_deactivation(record, location)
    end
  end

  def validate_reactivation(record, recent_deactivation, location)
    if record.reactivation_date.blank?
      if record.reactivation_date_type.blank?
        record.errors.add(:reactivation_date_type, message: I18n.t("validations.location.toggle_date.not_selected"))
      elsif record.reactivation_date_type == "other"
        record.errors.add(:reactivation_date, message: I18n.t("validations.location.toggle_date.invalid"))
      end
    elsif record.reactivation_date.before? location.available_from
      record.errors.add(:reactivation_date, message: I18n.t("validations.location.toggle_date.out_of_range", date: location.available_from.to_formatted_s(:govuk_date)))
    elsif record.reactivation_date < recent_deactivation.deactivation_date
      record.errors.add(:reactivation_date, message: I18n.t("validations.location.reactivation.before_deactivation", date: recent_deactivation.deactivation_date.to_formatted_s(:govuk_date)))
    end
  end

  def validate_deactivation(record, location)
    if record.deactivation_date.blank?
      if record.deactivation_date_type.blank?
        record.errors.add(:deactivation_date_type, message: I18n.t("validations.location.toggle_date.not_selected"))
      elsif record.deactivation_date_type == "other"
        record.errors.add(:deactivation_date, message: I18n.t("validations.location.toggle_date.invalid"))
      end
    elsif location.location_deactivation_periods.any? { |period| period.reactivation_date.present? && record.deactivation_date.between?(period.deactivation_date, period.reactivation_date - 1.day) }
      record.errors.add(:deactivation_date, message: I18n.t("validations.location.deactivation.during_deactivated_period"))
    elsif record.deactivation_date.before? FormHandler.instance.start_date_of_earliest_open_for_editing_collection_period
      record.errors.add(:deactivation_date, message: I18n.t("validations.location.toggle_date.out_of_range", date: FormHandler.instance.start_date_of_earliest_open_for_editing_collection_period.to_formatted_s(:govuk_date)))
    elsif record.deactivation_date.before? location.available_from
      record.errors.add(:deactivation_date, message: I18n.t("validations.location.toggle_date.before_creation", date: location.available_from.to_formatted_s(:govuk_date)))
    end
  end
end

class LocationDeactivationPeriod < ApplicationRecord
  validates_with LocationDeactivationPeriodValidator
  belongs_to :location
  attr_accessor :deactivation_date_type, :reactivation_date_type

  scope :deactivations_without_reactivation, -> { where(reactivation_date: nil) }
  scope :deactivations_with_reactivation, -> { where.not(reactivation_date: nil) }

  def includes_date?(date)
    deactivation_date <= date && (reactivation_date.nil? or reactivation_date > date)
  end
end
