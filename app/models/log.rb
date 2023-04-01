class Log < ApplicationRecord
  include CollectionTimeHelper

  self.abstract_class = true

  belongs_to :owning_organisation, class_name: "Organisation", optional: true
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true
  belongs_to :bulk_upload, optional: true

  before_save :update_status!

  STATUS = {
    "not_started" => 0,
    "in_progress" => 1,
    "completed" => 2,
    "pending" => 3,
  }.freeze
  enum status: STATUS
  enum status_cache: STATUS, _prefix: true

  scope :visible, -> { where(status: %w[not_started in_progress completed]) }

  scope :filter_by_status, ->(status, _user = nil) { where status: }
  scope :filter_by_years, lambda { |years, _user = nil|
    first_year = years.shift
    query = filter_by_year(first_year)
    years.each { |year| query = query.or(filter_by_year(year)) }
    query.all
  }
  scope :filter_by_postcode, ->(postcode_full) { where("REPLACE(postcode_full, ' ', '') ILIKE ?", "%#{postcode_full.delete(' ')}%") }
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

  attr_accessor :skip_update_status

  def process_uprn_change!
    if uprn.present?
      service = UprnClient.new(uprn)
      service.call

      return errors.add(:uprn, service.error) if service.error.present?

      presenter = UprnDataPresenter.new(service.result)

      self.uprn_known = 1
      self.uprn_confirmed = nil
      self.address_line1 = presenter.address_line1
      self.address_line2 = presenter.address_line2
      self.town_or_city = presenter.town_or_city
      self.postcode_full = presenter.postcode
      self.county = nil
      process_postcode_changes!
    end
  end

  def collection_start_year
    return @start_year if @start_year

    return unless startdate

    window_end_date = Time.zone.local(startdate.year, 4, 1)
    @start_year = startdate < window_end_date ? startdate.year - 1 : startdate.year
  end

  def recalculate_start_year!
    @start_year = nil
    collection_start_year
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
    return false if older_than_previous_collection_year?

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

  (2..8).each do |person_num|
    define_method("person_#{person_num}_child_relation?") do
      send("relat#{person_num}") == "C"
    end
  end

  def calculate_status
    if all_fields_completed? && errors.empty?
      "completed"
    elsif all_fields_nil?
      "not_started"
    else
      "in_progress"
    end
  end

  def field_formatted_as_currency(field_name)
    field_value = public_send(field_name)
    format_as_currency(field_value)
  end

private

  # Handle logs that are older than previous collection start date
  def older_than_previous_collection_year?
    return false unless startdate

    startdate < previous_collection_start_date
  end

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
    return if skip_update_status

    self.status = calculate_status
  end

  def all_fields_completed?
    form.subsections.all? { |subsection| subsection.complete?(self) || subsection.not_displayed_in_tasklist?(self) }
  end

  def all_fields_nil?
    not_started_statuses = %i[not_started cannot_start_yet]
    form.subsections.all? { |subsection| not_started_statuses.include? subsection.status(self) }
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

  LA_CHANGES = {
    "E07000027" => "E06000064", # Barrow-in-Furness => Westmorland and Furness
    "E07000030" => "E06000064", # Eden => Westmorland and Furness
    "E07000031" => "E06000064", # South Lakeland => Westmorland and Furness
    "E07000026" => "E06000063", # Allerdale => Cumberland
    "E07000028" => "E06000063", # Carlisle => Cumberland
    "E07000029" => "E06000063", # Copeland => Cumberland
    "E07000163" => "E06000065", # Craven => North Yorkshire
    "E07000164" => "E06000065", # Hambleton => North Yorkshire
    "E07000165" => "E06000065", # Harrogate => North Yorkshire
    "E07000166" => "E06000065", # Richmondshire => North Yorkshire
    "E07000167" => "E06000065", # Ryedale => North Yorkshire
    "E07000168" => "E06000065", # Scarborough => North Yorkshire
    "E07000169" => "E06000065", # Selby => North Yorkshire
    "E07000187" => "E06000066", # Mendip => Somerset
    "E07000188" => "E06000066", # Sedgemoor => Somerset
    "E07000246" => "E06000066", # Somerset West and Taunton => Somerset
    "E07000189" => "E06000066", # South Somerset => Somerset
  }.freeze

  def get_inferred_la(postcode)
    result = PIO.lookup(postcode)
    location_code = result[:location_code] if result
    if LA_CHANGES.key?(location_code) && form.start_date.year >= 2023
      LA_CHANGES[location_code]
    elsif !(LA_CHANGES.value?(location_code) && form.start_date.year < 2023)
      location_code
    end
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
