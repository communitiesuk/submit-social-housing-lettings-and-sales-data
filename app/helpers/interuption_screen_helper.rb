module InteruptionScreenHelper
  def display_informative_text(informative_text, case_log)
    translation_question = informative_text["argument"].map { |x| case_log.form.get_question(x) }
    translation = I18n.t(informative_text["translation"], informative_text["argument"][0].to_sym => translation_question[0].answer_label(case_log), informative_text["argument"][1].to_sym => translation_question[1].answer_label(case_log))
    "<span>#{translation}</span>".html_safe
  end
end
