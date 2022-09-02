module FormPageErrorHelper
  def remove_other_page_errors(lettings_log, page)
    other_page_error_ids = lettings_log.errors.map(&:attribute) - page.questions.map { |q| q.id.to_sym }.concat([:base])
    other_page_error_ids.each { |id| lettings_log.errors.delete(id) }
  end
end
