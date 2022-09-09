class AllLog < ApplicationRecord
  self.table_name = :logs

  STATUS = { "not_started" => 0, "in_progress" => 1, "completed" => 2 }.freeze
  enum status: STATUS

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
    User.find(created_by_id)
  end
end
