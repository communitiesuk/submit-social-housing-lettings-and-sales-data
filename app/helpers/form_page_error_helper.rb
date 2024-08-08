module FormPageErrorHelper
  def remove_other_page_errors(lettings_log, page)
    other_page_error_ids = lettings_log.errors.map(&:attribute) - page.questions.map { |q| q.id.to_sym }.concat([:base])
    other_page_error_ids.each { |id| lettings_log.errors.delete(id) }
  end

  def remove_duplicate_page_errors(lettings_log)
    lettings_log.errors.map(&:message)
    lettings_log.errors.group_by(&:message).each do |_, errors|
      next if errors.size == 1

      errors.shift
      errors.each { |error| lettings_log.errors.delete(error.attribute) }
    end
  end

  def all_questions_affected_by_errors(log)
    log.errors.map(&:attribute) - [:base]
  end
end
