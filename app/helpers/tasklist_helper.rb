module TasklistHelper
  include GovukLinkHelper

  def get_next_incomplete_section(log)
    log.form.subsections.find { |subsection| subsection.is_incomplete?(log) }
  end

  def get_subsections_count(log, status = :all)
    return log.form.subsections.count { |subsection| subsection.applicable_questions(log).count.positive? } if status == :all

    log.form.subsections.count { |subsection| subsection.status(log) == status && subsection.applicable_questions(log).count.positive? }
  end

  def next_page_or_check_answers(subsection, log, current_user)
    path = if subsection.is_started?(log)
             "#{log.class.name.underscore}_#{subsection.id}_check_answers_path"
           else
             "#{log.class.name.underscore}_#{next_question_page(subsection, log, current_user)}_path"
             end
    if log.id
      send(path, log)
    else
      "/#{log.lettings? ? "lettings" : "sales"}-logs/new/#{next_question_page(subsection, log, current_user)}"
    end
  end

  def next_question_page(subsection, log, current_user)
    if subsection.pages.first.routed_to?(log, current_user)
      subsection.pages.first.id
    else
      log.form.next_page(subsection.pages.first, log, current_user)
    end
  end

  def subsection_link(subsection, log, current_user)
    if subsection.status(log) != :cannot_start_yet
      next_page_path = next_page_or_check_answers(subsection, log, current_user).to_s
      govuk_link_to(subsection.label, next_page_path.dasherize, aria: { describedby: subsection.id.dasherize })
    else
      subsection.label
    end
  end
end
