module InteruptionScreenHelper
  def display_informative_text(informative_text, case_log)
    arguments = informative_text["argument"].map { |x, type| type == "question" ? case_log.form.get_question(x, case_log).answer_label(case_log) : case_log.public_send(x) }
    keys = informative_text["argument"].keys

    begin
      translation = I18n.t(informative_text["translation"], keys[0].present? ? keys[0].to_sym : "" => arguments[0], keys[1].present? ? keys[1].to_sym : "" => arguments[1], keys[2].present? ? keys[2].to_sym : "" => arguments[2])
    rescue StandardError
      return ""
    end
    translation.to_s.html_safe
  end
end
