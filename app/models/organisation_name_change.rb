class OrganisationNameChange < ApplicationRecord
  belongs_to :organisation

  scope :visible, -> { where(discarded_at: nil) }
  scope :before_date, ->(date) { where("startdate < ?", date) }
  scope :after_date, ->(date) { where("startdate > ?", date) }

  validates :name, presence: true
  validates :startdate, presence: true, unless: -> { immediate_change }
  validate :startdate_must_be_after_last_change
  validate :name_must_be_different_from_current
  validate :startdate_must_be_unique_for_organisation
  validate :startdate_must_be_before_merge_date

  attr_accessor :immediate_change

  before_validation :set_startdate_if_immediate

  CHANGE_TYPE = {
    user_change: 1,
    merge: 2,
  }.freeze

  enum :change_type, CHANGE_TYPE, prefix: true

  has_paper_trail

  def status
    if startdate > Time.zone.now.to_date
      "scheduled"
    elsif end_date.nil? || end_date >= Time.zone.now.to_date
      "active"
    else
      "inactive"
    end
  end

  def includes_date?(date)
    startdate <= date && (next_change&.startdate.nil? || next_change&.startdate > date)
  end

  def next_change
    organisation.organisation_name_changes.where("startdate > ?", startdate).order(startdate: :asc).first
  end

  def end_date
    next_change&.startdate&.yesterday
  end

  def previous_change
    organisation.organisation_name_changes.where("startdate < ?", startdate).order(startdate: :desc).first
  end

  def active?(date = Time.zone.now)
    includes_date?(date)
  end

  def formatted_startdate(format = :govuk_date)
    startdate.to_formatted_s(format)
  end

private

  def set_startdate_if_immediate
    self.startdate ||= Time.zone.now if immediate_change
  end

  def startdate_must_be_after_last_change
    return if startdate.blank?

    last_startdate = organisation.organisation_name_changes
                                   .visible
                                   .where("startdate < ?", startdate)
                                   .order(startdate: :desc)
                                   .first&.startdate

    if last_startdate && startdate <= last_startdate
      errors.add(:startdate, "Start date must be after the last change date (#{last_startdate}).")
    end
  end

  def startdate_must_be_unique_for_organisation
    return if startdate.blank?

    if organisation.organisation_name_changes.visible.select(&:persisted?).any? { |record| record.startdate == startdate }
      errors.add(:startdate, "Start date cannot be the same as another name change.") unless immediate_change
      errors.add(:immediate_change, "Start date cannot be the same as another name change.") if immediate_change
    end
  end

  def name_must_be_different_from_current
    return if name.blank? || startdate.blank?

    if name == organisation.name(date: startdate)
      errors.add(:name, "New name must be different from the current name on the change date.")
    end
  end

  def startdate_must_be_before_merge_date
    return if startdate.blank? || organisation.merge_date.blank?

    if startdate >= organisation.merge_date
      errors.add(:startdate, "Start date must be earlier than the organisation's merge date (#{organisation.merge_date.to_formatted_s(:govuk_date)}). You cannot make changes to the name of an organisation after it has merged.") unless immediate_change
      errors.add(:immediate_change, "Start date must be earlier than the organisation's merge date (#{organisation.merge_date.to_formatted_s(:govuk_date)}). You cannot make changes to the name of an organisation after it has merged.") if immediate_change
    end
  end
end
