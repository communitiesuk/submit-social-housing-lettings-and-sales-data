module TasklistHelper
  include GovukLinkHelper

  def get_next_incomplete_section(case_log)
    case_log.form.subsections.find { |subsection| subsection.is_incomplete?(case_log) }
  end

  def get_subsections_count(case_log, status = :all)
    return case_log.form.subsections.count if status == :all

    case_log.form.subsections.count { |subsection| subsection.status(case_log) == status }
  end

  def next_page_or_check_answers(subsection, case_log, current_user)
    path = if subsection.is_started?(case_log)
             "case_log_#{subsection.id}_check_answers_path"
           else
             "case_log_#{next_question_page(subsection, case_log, current_user)}_path"
           end
    send(path, case_log)
  end

  def next_question_page(subsection, case_log, current_user)
    if subsection.pages.first.routed_to?(case_log, current_user)
      subsection.pages.first.id
    else
      case_log.form.next_page(subsection.pages.first, case_log, current_user)
    end
  end

  def subsection_link(subsection, case_log, current_user)
    if subsection.status(case_log) != :cannot_start_yet
      next_page_path = next_page_or_check_answers(subsection, case_log, current_user).to_s
      govuk_link_to(subsection.label, next_page_path.dasherize, aria: { describedby: subsection.id.dasherize })
    else
      subsection.label
    end
  end
end
