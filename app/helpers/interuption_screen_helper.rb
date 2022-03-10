module InteruptionScreenHelper
  def display_informative_text(informative_text, case_log)
    translation_questions = informative_text["argument"].map { |x| case_log.form.get_question(x) }
    begin
      case translation_questions.count
      when 2
        translation = I18n.t(informative_text["translation"], informative_text["argument"][0].to_sym => translation_questions[0].answer_label(case_log), informative_text["argument"][1].to_sym => translation_questions[1].answer_label(case_log))
      when 1
        translation = I18n.t(informative_text["translation"], informative_text["argument"][0].to_sym => translation_questions[0].answer_label(case_log))
      end
    rescue StandardError
      return ""
    end
    "#{translation}".html_safe
  end
end
