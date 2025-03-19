class SchemeDeactivationPeriodValidator < ActiveModel::Validator
  include CollectionTimeHelper

  def validate(record)
    scheme = record.scheme
    open_deactivation = scheme.scheme_deactivation_periods.deactivations_without_reactivation.first

    # The SchemesController validates deactivation periods in three places:
    # 1. new_deactivation builds a temporary scheme_deactivation_period object using the open deactivation if it starts in over six months, or otherwise builds a new period, and validates this (want validate_deactivation)
    # 2. `deactivate` takes the open deactivation if present (any start date) and update!s it with the deactivation date, or else create!s a new deactivation with the deactivation date (want validate_deactivation)
    # 3. `reactivate` takes the open deactivation (any start date) and update!s it with the reactivation date (want validate_reactivation)
    # In toggle_scheme_link in SchemesHelper, we display a link to one or neither of new_deactivation and new_reactivation depending on status now and status in six months.
    if open_deactivation.present? && open_deactivation.deactivation_date <= 6.months.from_now
      validate_reactivation(record, open_deactivation, scheme)
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
    if record.deactivation_date.blank?
      if record.deactivation_date_type.blank?
        record.errors.add(:deactivation_date_type, message: I18n.t("validations.scheme.toggle_date.not_selected"))
      elsif record.deactivation_date_type == "other"
        record.errors.add(:deactivation_date, message: I18n.t("validations.scheme.toggle_date.invalid"))
      end
    elsif scheme.scheme_deactivation_periods.any? { |period| period.reactivation_date.present? && record.deactivation_date.between?(period.deactivation_date, period.reactivation_date - 1.day) }
      record.errors.add(:deactivation_date, message: I18n.t("validations.scheme.deactivation.during_deactivated_period"))
    elsif record.deactivation_date.before? FormHandler.instance.start_date_of_earliest_open_for_editing_collection_period
      record.errors.add(:deactivation_date, message: I18n.t("validations.scheme.toggle_date.out_of_range", date: FormHandler.instance.start_date_of_earliest_open_for_editing_collection_period.to_formatted_s(:govuk_date)))
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
  scope :deactivations_with_reactivation, -> { where.not(reactivation_date: nil) }

  def includes_date?(date)
    deactivation_date <= date && (reactivation_date.nil? or reactivation_date > date)
  end
end
