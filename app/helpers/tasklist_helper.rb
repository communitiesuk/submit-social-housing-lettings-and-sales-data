module TasklistHelper
  include GovukLinkHelper

  def get_next_incomplete_section(lettings_log)
    lettings_log.form.subsections.find { |subsection| subsection.is_incomplete?(lettings_log) }
  end

  def get_subsections_count(lettings_log, status = :all)
    return lettings_log.form.subsections.count { |subsection| subsection.applicable_questions(lettings_log).count.positive? } if status == :all

    lettings_log.form.subsections.count { |subsection| subsection.status(lettings_log) == status && subsection.applicable_questions(lettings_log).count.positive? }
  end

  def next_page_or_check_answers(subsection, log, current_user)
    path = if subsection.is_started?(log)
             "#{log.class.name.underscore}_#{subsection.id}_check_answers_path"
           else
             "#{log.class.name.underscore}_#{next_question_page(subsection, log, current_user)}_path"
           end
    send(path, log)
  end

  def next_question_page(subsection, lettings_log, current_user)
    if subsection.pages.first.routed_to?(lettings_log, current_user)
      subsection.pages.first.id
    else
      lettings_log.form.next_page(subsection.pages.first, lettings_log, current_user)
    end
  end

  def subsection_link(subsection, lettings_log, current_user)
    if subsection.status(lettings_log) != :cannot_start_yet
      next_page_path = next_page_or_check_answers(subsection, lettings_log, current_user).to_s
      govuk_link_to(subsection.label, next_page_path.dasherize, aria: { describedby: subsection.id.dasherize })
    else
      subsection.label
    end
  end
end
