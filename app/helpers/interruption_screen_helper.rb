module InterruptionScreenHelper
  def display_informative_text(informative_text, log)
    return "" unless informative_text["arguments"]

    translation_params = {}
    informative_text["arguments"].each do |argument|
      value = get_value_from_argument(log, argument)
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

  def display_title_text(title_text, log)
    return "" if title_text.nil?

    translation_params = {}
    arguments = title_text["arguments"] || {}
    arguments.each do |argument|
      value = get_value_from_argument(log, argument)
      translation_params[argument["i18n_template"].to_sym] = value
    end
    I18n.t(title_text["translation"], **translation_params).to_s
  end

private

  def get_value_from_argument(log, argument)
    if argument["label"]
      log.form.get_question(argument["key"], log).answer_label(log).downcase
    elsif argument["arguments_for_public_send"]
      log.public_send(argument["key"], argument["arguments_for_public_send"])
    else
      log.public_send(argument["key"])
    end
  end
end
