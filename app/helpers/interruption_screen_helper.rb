module InterruptionScreenHelper
  def display_informative_text(informative_text, case_log)
    return "" unless informative_text["arguments"]

    translation_params = {}
    informative_text["arguments"].each do |argument|
      value = if argument["label"]
                case_log.form.get_question(argument["key"], case_log).answer_label(case_log).downcase
              else
                case_log.public_send(argument["key"])
              end
      translation_params[argument["i18n_template"].to_sym] = value
    end

    begin
      translation = I18n.t(informative_text["translation"], **translation_params)
      translation.to_s.html_safe
    rescue I18n::MissingInterpolationArgument => e
      Rails.logger.error(e.message)
      ""
    end
  end

  def display_title_text(title_text, case_log)
    return "" if title_text.nil?

    translation_params = {}
    arguments = title_text["arguments"] || {}
    arguments.each do |argument|
      value = if argument["label"]
                case_log.form.get_question(argument["key"], case_log).answer_label(case_log).downcase
              else
                case_log.public_send(argument["key"])
              end
      translation_params[argument["i18n_template"].to_sym] = value
    end
    I18n.t(title_text["translation"], **translation_params).to_s
  end
end
