class SchemeDeactivationPeriodValidator < ActiveModel::Validator
  include CollectionTimeHelper

  def validate(record)
    scheme = record.scheme
    recent_deactivation = scheme.scheme_deactivation_periods.deactivations_without_reactivation.first
    if recent_deactivation.present?
      validate_reactivation(record, recent_deactivation, scheme)
    else
      validate_deactivation(record, scheme)
    end
  end

  def validate_reactivation(record, recent_deactivation, scheme)
    if record.reactivation_date.blank?
      if record.reactivation_date_type.blank?
        record.errors.add(:reactivation_date_type, message: I18n.t("validations.scheme.toggle_date.not_selected"))
      elsif record.reactivation_date_type == "other"
        record.errors.add(:reactivation_date, message: I18n.t("validations.scheme.toggle_date.invalid"))
      end
    elsif !record.reactivation_date.between?(scheme.available_from, Time.zone.local(2200, 1, 1))
      record.errors.add(:reactivation_date, message: I18n.t("validations.scheme.toggle_date.out_of_range", date: scheme.available_from.to_formatted_s(:govuk_date)))
    elsif record.reactivation_date < recent_deactivation.deactivation_date
      record.errors.add(:reactivation_date, message: I18n.t("validations.scheme.reactivation.before_deactivation", date: recent_deactivation.deactivation_date.to_formatted_s(:govuk_date)))
    end
  end

  def validate_deactivation(record, scheme)
    earliest_possible_deactivation = FormHandler.instance.in_crossover_period? ? previous_collection_start_date : current_collection_start_date

    if record.deactivation_date.blank?
      if record.deactivation_date_type.blank?
        record.errors.add(:deactivation_date_type, message: I18n.t("validations.scheme.toggle_date.not_selected"))
      elsif record.deactivation_date_type == "other"
        record.errors.add(:deactivation_date, message: I18n.t("validations.scheme.toggle_date.invalid"))
      end
    elsif scheme.scheme_deactivation_periods.any? { |period| period.reactivation_date.present? && record.deactivation_date.between?(period.deactivation_date, period.reactivation_date - 1.day) }
      record.errors.add(:deactivation_date, message: I18n.t("validations.scheme.deactivation.during_deactivated_period"))
    elsif record.deactivation_date.before? earliest_possible_deactivation
      record.errors.add(:deactivation_date, message: I18n.t("validations.scheme.toggle_date.out_of_range", date: earliest_possible_deactivation.to_formatted_s(:govuk_date)))
    elsif record.deactivation_date.before? scheme.available_from
      record.errors.add(:deactivation_date, message: I18n.t("validations.scheme.toggle_date.before_creation", date: scheme.available_from.to_formatted_s(:govuk_date)))
    end
  end
end

class SchemeDeactivationPeriod < ApplicationRecord
  validates_with SchemeDeactivationPeriodValidator
  belongs_to :scheme
  attr_accessor :deactivation_date_type, :reactivation_date_type

  scope :deactivations_without_reactivation, -> { where(reactivation_date: nil) }
end
