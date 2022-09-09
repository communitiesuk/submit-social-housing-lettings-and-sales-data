class Log < ApplicationRecord
  self.abstract_class = true

  belongs_to :owning_organisation, class_name: "Organisation", optional: true
  belongs_to :managing_organisation, class_name: "Organisation", optional: true
  belongs_to :created_by, class_name: "User", optional: true

  STATUS = { "not_started" => 0, "in_progress" => 1, "completed" => 2 }.freeze
  enum status: STATUS

  scope :combined, -> { ActiveRecord::Base.connection.execute("SELECT * FROM logs") }

  def collection_start_year
    return @start_year if @start_year
    return unless startdate

    window_end_date = Time.zone.local(startdate.year, 4, 1)
    @start_year = startdate < window_end_date ? startdate.year - 1 : startdate.year
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
end
