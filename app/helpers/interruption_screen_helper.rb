module InterruptionScreenHelper
  def display_informative_text(informative_text, lettings_log)
    return "" unless informative_text["arguments"]

    translation_params = {}
    informative_text["arguments"].each do |argument|
      value = if argument["label"]
                pre_casing_value = lettings_log.form.get_question(argument["key"], lettings_log).answer_label(lettings_log)
                pre_casing_value.downcase
              elsif argument["currency"]
                ["£", ActionController::Base.helpers.number_to_currency(lettings_log.public_send(argument["key"]), delimiter: ",", format: "%n")].join("")
              else
                lettings_log.public_send(argument["key"])
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

  def display_title_text(title_text, lettings_log)
    return "" if title_text.nil?

    translation_params = {}
    arguments = title_text["arguments"] || {}
    arguments.each do |argument|
      value = if argument["label"]
                lettings_log.form.get_question(argument["key"], lettings_log).answer_label(lettings_log).downcase
              elsif argument["currency"]
                ["£", ActionController::Base.helpers.number_to_currency(lettings_log.public_send(argument["key"]), delimiter: ",", format: "%n")].join("")
              else
                lettings_log.public_send(argument["key"])
              end
      translation_params[argument["i18n_template"].to_sym] = value
    end
    I18n.t(title_text["translation"], **translation_params).to_s
  end
end
