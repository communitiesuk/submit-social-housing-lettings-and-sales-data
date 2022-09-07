class Log < ApplicationRecord
  self.abstract_class = true

  belongs_to :owning_organisation, class_name: "Organisation", optional: true
  belongs_to :managing_organisation, class_name: "Organisation", optional: true
  belongs_to :created_by, class_name: "User", optional: true

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
