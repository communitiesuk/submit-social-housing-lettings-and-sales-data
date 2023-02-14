class Log < ApplicationRecord
  self.abstract_class = true

  belongs_to :owning_organisation, class_name: "Organisation", optional: true
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true
  belongs_to :bulk_upload, optional: true

  before_save :update_status!

  STATUS = { "not_started" => 0, "in_progress" => 1, "completed" => 2 }.freeze
  enum status: STATUS

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
  scope :filter_by_bulk_upload_id, lambda { |bulk_upload_id, user|
    joins(:bulk_upload)
      .where(bulk_upload: { id: bulk_upload_id, user: })
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

  def sales?
    false
  end

  def ethnic_refused?
    ethnic_group == 17
  end

  def collection_period_open?
    form.end_date > Time.zone.today
  end

  def blank_invalid_non_setup_fields!
    setup_ids = form.setup_sections.flat_map(&:subsections).flat_map(&:questions).map(&:id)

    errors.each do |error|
      next if setup_ids.include?(error.attribute.to_s)

      public_send("#{error.attribute}=", nil)
    end
  end

  (1..8).each do |person_num|
    define_method("retirement_age_for_person_#{person_num}") do
      retirement_age_for_person(person_num)
    end

    define_method("plural_gender_for_person_#{person_num}") do
      plural_gender_for_person(person_num)
    end
  end

private

  def plural_gender_for_person(person_num)
    gender = public_send("sex#{person_num}".to_sym)
    return unless gender

    if %w[M X].include?(gender)
      "male and non-binary people"
    elsif gender == "F"
      "females"
    end
  end

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
