module CheckAnswersHelper
  include GovukLinkHelper

  def display_answered_questions_summary(subsection, lettings_log, current_user)
    total = total_count(subsection, lettings_log, current_user)
    answered = answered_questions_count(subsection, lettings_log, current_user)
    if total == answered
      '<p class="govuk-body">You answered all the questions.</p>'.html_safe
    else
      "<p class=\"govuk-body\">You have answered #{answered} of #{total} questions.</p>".html_safe
    end
  end

  def can_change_scheme_answer?(attribute_name, scheme)
    editable_attributes = current_user.support? ? ["Name", "Confidential information", "Housing stock owned by"] : ["Name", "Confidential information"]
    !scheme.confirmed? || editable_attributes.include?(attribute_name)
  end

  def get_location_change_link_href_postcode(scheme, location)
    if location.confirmed?
      location_edit_name_path(id: scheme.id, location_id: location.id)
    else
      location_edit_path(id: scheme.id, location_id: location.id)
    end
  end

  def get_location_change_link_href_location_admin_district(scheme, location)
    location_edit_local_authority_path(id: scheme.id, location_id: location.id)
  end

  def any_questions_have_summary_card_number?(subsection, lettings_log)
    subsection.applicable_questions(lettings_log).map(&:check_answers_card_number).compact.length.positive?
  end

  def next_incomplete_section_path(log, redirect_path)
    "#{log.class.name.underscore}_#{redirect_path.underscore.tr('/', '_')}_path"
  end

private

  def answered_questions_count(subsection, lettings_log, current_user)
    answered_questions(subsection, lettings_log, current_user).count
  end

  def answered_questions(subsection, lettings_log, current_user)
    total_applicable_questions(subsection, lettings_log, current_user).select { |q| q.completed?(lettings_log) }
  end

  def total_count(subsection, lettings_log, current_user)
    total_applicable_questions(subsection, lettings_log, current_user).count
  end

  def total_applicable_questions(subsection, lettings_log, current_user)
    subsection.applicable_questions(lettings_log).reject { |q| q.hidden_in_check_answers?(lettings_log, current_user) }
  end

  def get_answer_label(question, lettings_log)
    question.answer_label(lettings_log).presence || "<span class=\"app-!-colour-muted\">You didn’t answer this question</span>".html_safe
  end
end
