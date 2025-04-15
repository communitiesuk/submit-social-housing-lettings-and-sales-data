class OrganisationNameChange < ApplicationRecord
  belongs_to :organisation

  scope :visible, -> { where(discarded_at: nil) }

  validates :name, presence: true
  validates :change_date, presence: true, unless: -> { immediate_change }
  validate :change_date_must_be_after_last_change_date
  validate :name_must_be_different_from_current
  validate :change_date_must_be_unique_for_organisation

  attr_accessor :immediate_change

  before_validation :set_change_date_if_immediate

  CHANGE_TYPE = {
    user_change: 1,
    merge: 2,
  }.freeze

  enum :change_type, CHANGE_TYPE, prefix: true

  has_paper_trail

  def includes_date?(date)
    change_date <= date && (next_change&.change_date.nil? || next_change&.change_date > date)
  end

  def before_date?(date)
    change_date < date
  end

  def after_date?(date)
    change_date > date
  end

  def next_change
    organisation.organisation_name_changes.where("change_date > ?", change_date).order(change_date: :asc).first
  end

  def previous_change
    organisation.organisation_name_changes.where("change_date < ?", change_date).order(change_date: :desc).first
  end

  def active?(date = Time.zone.now)
    includes_date?(date)
  end

  def formatted_change_date(format = :govuk_date)
    change_date.to_formatted_s(format)
  end

private

  def set_change_date_if_immediate
    self.change_date = Time.zone.now if immediate_change
  end

  def change_date_must_be_after_last_change_date
    return if change_date.blank?

    last_change_date = organisation.organisation_name_changes
                                   .visible
                                   .where("change_date < ?", change_date)
                                   .order(change_date: :desc)
                                   .first&.change_date

    if last_change_date && change_date <= last_change_date
      errors.add(:change_date, "Start date must be after the last change date (#{last_change_date}).")
    end
  end

  def change_date_must_be_unique_for_organisation
    return if change_date.blank?

    if organisation.organisation_name_changes.visible.select(&:persisted?).any? { |record| record.change_date == change_date }
      errors.add(:change_date, "Start date cannot be the same as an existing name change.")
    end
  end

  def name_must_be_different_from_current
    return if name.blank? || change_date.blank?

    if name == organisation.name(date: change_date)
      errors.add(:name, "New name must be different from the current name on the change date.")
    end
  end
end

