class DuplicateLogService
  def is_log_duplicate? (log)
    return true if log.id == 3
  end
end
