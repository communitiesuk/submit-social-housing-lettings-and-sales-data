class AllLog < ApplicationRecord
  self.table_name = :logs

  STATUS = { "not_started" => 0, "in_progress" => 1, "completed" => 2 }.freeze
  enum status: STATUS

  belongs_to :owning_organisation, class_name: "Organisation", optional: true
  belongs_to :managing_organisation, class_name: "Organisation", optional: true
  belongs_to :created_by, class_name: "User", optional: true

  def read_only?
    true
  end

  def tenancycode?
    log_type == "lettings"
  end

  def needstype?
    log_type == "lettings"
  end

  def startdate?
    false
  end

  def is_general_needs?
    log_type == "lettings"
  end

  def created_by
    User.find(created_by_id) if created_by_id.present?
  end

  def owning_organisation
    Organisation.find(owning_organisation_id) if owning_organisation_id.present?
  end

  def managing_organisation
    Organisation.find(managing_organisation_id) if managing_organisation_id.present?
  end
end
