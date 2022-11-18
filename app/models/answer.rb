class Answer
  attr_reader :question, :log

  delegate :type, to: :question
  delegate :id, to: :question
  delegate :answer_options, to: :question
  delegate :prefix, to: :question
  delegate :suffix, to: :question
  delegate :inferred_check_answers_value, to: :question
  delegate :inferred_answers, to: :question

  delegate :page, to: :question
  delegate :subsection, to: :page
  delegate :form, to: :subsection

  def initialize(question:, log:)
    @question = question
    @log = log
  end

  def answer_label
    return checkbox_answer_label if checkbox?
    return log[id]&.to_formatted_s(:govuk_date).to_s if date?

    answer = label_from_value(log[id]) if log[id].present?
    answer_label = [prefix, format_value(answer), suffix_label].join("") if answer

    inferred = inferred_check_answers_value["value"] if inferred_check_answers_value && has_inferred_check_answers_value?

    return inferred if inferred.present?

    answer_label
  end

  def suffix_label
    return "" unless suffix
    return suffix if suffix.is_a?(String)

    label = ""

    suffix.each do |s|
      condition = s["depends_on"]
      next unless condition

      answer = log.send(condition.keys.first)
      if answer == condition.values.first
        label = s["label"]
      end
    end
    label
  end

  def completed?
    return answer_options.keys.any? { |key| value_is_yes?(log[key]) } if checkbox?

    log[id].present? || !log.respond_to?(id.to_sym) || has_inferred_display_value?
  end

  def get_inferred_answers
    return [] unless inferred_answers

    enabled_inferred_answers(inferred_answers).keys.map do |question_id|
      question = form.get_question(question_id, log)
      if question.present?
        question.label_from_value(log[question_id])
      else
        Array(question_id.to_s.split(".")).inject(log) { |l, method| l.present? ? l.public_send(*method) : "" }
      end
    end
  end

private

  def enabled_inferred_answers(inferred_answers)
    inferred_answers.filter { |_key, value| value.all? { |condition_key, condition_value| log[condition_key] == condition_value } }
  end

  def has_inferred_display_value?
    inferred_check_answers_value.present? && log[inferred_check_answers_value["condition"].keys.first] == inferred_check_answers_value["condition"].values.first
  end

  def has_inferred_check_answers_value?
    return true if selected_answer_option_is_derived?
    return inferred_check_answers_value["condition"].values[0] == log[inferred_check_answers_value["condition"].keys[0]] if inferred_check_answers_value.present?

    false
  end

  def selected_answer_option_is_derived?
    selected_option = answer_options&.dig(log[id].to_s.presence)
    selected_option.is_a?(Hash) && selected_option["depends_on"] && form.depends_on_met(selected_option["depends_on"], log)
  end

  def format_value(answer_label)
    if prefix == "£"
      ActionController::Base.helpers.number_to_currency(answer_label, delimiter: ",", format: "%n")
    else
      answer_label
    end
  end

  def label_from_value(value)
    question.label_from_value(value)
  end

  def checkbox?
    question.type == "checkbox"
  end

  def date?
    question.type == "date"
  end

  def checkbox_answer_label
    answer = []
    return "Yes" if declaration? && value_is_yes?(log["declaration"])

    answer_options.each { |key, options| value_is_yes?(log[key]) ? answer << options["value"] : nil }
    answer.join(", ")
  end

  def declaration?
    question.id == "declaration"
  end

  def value_is_yes?(value)
    case type
    when "checkbox"
      value == 1
    when "radio"
      RADIO_YES_VALUE[id.to_sym]&.include?(value)
    else
      %w[yes].include?(value.downcase)
    end
  end
end
