module FormPageErrorHelper
  def remove_other_page_errors(case_log, page)
    other_page_error_ids = case_log.errors.map(&:attribute) - page.questions.map { |q| q.id.to_sym }.concat([:base])
    other_page_error_ids.each { |id| case_log.errors.delete(id) }
  end
end
