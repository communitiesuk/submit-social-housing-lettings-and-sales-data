class SchemeDeactivationPeriodValidator < ActiveModel::Validator
  def validate(record)
    if record.deactivation_date.blank?
      if record.deactivation_date_type.blank?
        record.errors.add(:deactivation_date_type, message: I18n.t("validations.scheme.deactivation_date.not_selected"))
      elsif record.deactivation_date_type == "other"
        record.errors.add(:deactivation_date, message: I18n.t("validations.scheme.deactivation_date.invalid"))
      end
    else
      collection_start_date = FormHandler.instance.current_collection_start_date
      unless record.deactivation_date.between?(collection_start_date, Time.zone.local(2200, 1, 1))
        record.errors.add(:deactivation_date, message: I18n.t("validations.scheme.deactivation_date.out_of_range", date: collection_start_date.to_formatted_s(:govuk_date)))
      end
    end
  end
end

class SchemeDeactivationPeriod < ApplicationRecord
  validates_with SchemeDeactivationPeriodValidator
  belongs_to :scheme
  attr_accessor :deactivation_date_type, :reactivation_date_type

  scope :deactivations_without_reactivation, -> { where(reactivation_date: nil) }
end
