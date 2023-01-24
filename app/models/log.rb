class Log < ApplicationRecord
  self.abstract_class = true

  belongs_to :owning_organisation, class_name: "Organisation", optional: true
  belongs_to :managing_organisation, class_name: "Organisation", optional: true
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true
  before_save :update_status!

  STATUS = { "not_started" => 0, "in_progress" => 1, "completed" => 2 }.freeze
  enum status: STATUS

  scope :filter_by_organisation, ->(org, _user = nil) { where(owning_organisation: org).or(where(managing_organisation: org)) }
  scope :filter_by_status, ->(status, _user = nil) { where status: }
  scope :filter_by_years, lambda { |years, _user = nil|
    first_year = years.shift
    query = filter_by_year(first_year)
    years.each { |year| query = query.or(filter_by_year(year)) }
    query.all
  }
  scope :filter_by_id, ->(id) { where(id:) }
  scope :filter_by_user, lambda { |selected_user, user|
    if !selected_user.include?("all") && user.present?
      where(created_by: user)
    end
  }
  scope :created_by, ->(user) { where(created_by: user) }

  def collection_start_year
    return @start_year if @start_year

    if lettings?
      return unless startdate

      log_start_date = startdate
    else
      return unless saledate

      log_start_date = saledate
    end

    window_end_date = Time.zone.local(log_start_date.year, 4, 1)
    @start_year = log_start_date < window_end_date ? log_start_date.year - 1 : log_start_date.year
  end

  def lettings?
    false
  end

  def ethnic_refused?
    ethnic_group == 17
  end

  def managing_organisation_provider_type
    managing_organisation&.provider_type
  end

  def collection_period_open?
    form.end_date > Time.zone.today
  end

private

  def update_status!
    self.status = if all_fields_completed? && errors.empty?
                    "completed"
                  elsif all_fields_nil?
                    "not_started"
                  else
                    "in_progress"
                  end
  end

  def all_fields_completed?
    subsection_statuses = form.subsections.map { |subsection| subsection.status(self) if subsection.displayed_in_tasklist?(self) }.uniq.compact
    subsection_statuses == [:completed]
  end

  def all_fields_nil?
    not_started_statuses = %i[not_started cannot_start_yet]
    subsection_statuses = form.subsections.map { |subsection| subsection.status(self) }.uniq
    subsection_statuses.all? { |status| not_started_statuses.include?(status) }
  end

  def reset_invalidated_dependent_fields!
    return unless form

    form.reset_not_routed_questions(self)

    reset_created_by!
  end

  def reset_created_by!
    return unless updated_by&.support?
    return if owning_organisation.blank? || managing_organisation.blank? || created_by.blank?
    return if created_by&.organisation == managing_organisation || created_by&.organisation == owning_organisation

    update!(created_by: nil)
  end

  PIO = PostcodeService.new

  def process_previous_postcode_changes!
    self.ppostcode_full = upcase_and_remove_whitespace(ppostcode_full)
    process_postcode(ppostcode_full, "ppcodenk", "is_previous_la_inferred", "prevloc")
  end

  def get_inferred_la(postcode)
    result = PIO.lookup(postcode)
    result[:location_code] if result
  end

  def upcase_and_remove_whitespace(string)
    string.present? ? string.upcase.gsub(/\s+/, "") : string
  end

  def reset_location_fields!
    reset_location(is_la_inferred, "la", "is_la_inferred", "postcode_full", 1)
  end

  def reset_previous_location_fields!
    reset_location(is_previous_la_inferred, "prevloc", "is_previous_la_inferred", "ppostcode_full", previous_la_known)
  end

  def reset_location(is_inferred, la_key, is_inferred_key, postcode_key, is_la_known)
    if is_inferred || is_la_known != 1
      self[la_key] = nil
    end
    self[is_inferred_key] = false
    self[postcode_key] = nil
  end
end
