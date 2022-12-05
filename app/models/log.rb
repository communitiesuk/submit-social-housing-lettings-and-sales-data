class Log < ApplicationRecord
  self.abstract_class = true

  belongs_to :owning_organisation, class_name: "Organisation", optional: true
  belongs_to :managing_organisation, class_name: "Organisation", optional: true
  belongs_to :created_by, class_name: "User", optional: true
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
    return unless startdate

    window_end_date = Time.zone.local(startdate.year, 4, 1)
    @start_year = startdate < window_end_date ? startdate.year - 1 : startdate.year
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
    subsection_statuses = form.subsections.map { |subsection| subsection.status(self) }.uniq
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
  end
end
