class Form::Question
  attr_accessor :id, :header, :hint_text, :description, :questions,
                :type, :min, :max, :step, :width, :fields_to_add, :result_field,
                :conditional_for, :readonly, :answer_options, :page, :check_answer_label,
                :inferred_answers, :hidden_in_check_answers, :inferred_check_answers_value,
                :guidance_partial, :prefix, :suffix, :requires_js

  def initialize(id, hsh, page)
    @id = id
    @check_answer_label = hsh["check_answer_label"]
    @header = hsh["header"]
    @guidance_partial = hsh["guidance_partial"]
    @hint_text = hsh["hint_text"]
    @type = hsh["type"]
    @min = hsh["min"]
    @max = hsh["max"]
    @step = hsh["step"]
    @width = hsh["width"]
    @fields_to_add = hsh["fields-to-add"]
    @result_field = hsh["result-field"]
    @readonly = hsh["readonly"]
    @answer_options = hsh["answer_options"]
    @conditional_for = hsh["conditional_for"]
    @inferred_answers = hsh["inferred_answers"]
    @inferred_check_answers_value = hsh["inferred_check_answers_value"]
    @hidden_in_check_answers = hsh["hidden_in_check_answers"]
    @prefix = hsh["prefix"]
    @suffix = hsh["suffix"]
    @requires_js = hsh["requires_js"]
    @page = page
  end

  delegate :subsection, to: :page
  delegate :form, to: :subsection

  def answer_label(case_log)
    return checkbox_answer_label(case_log) if type == "checkbox"
    return case_log[id]&.to_formatted_s(:govuk_date).to_s if type == "date"

    return case_log[id].to_s if case_log[id].present?

    has_inferred_check_answers_value?(case_log) ? inferred_check_answers_value["value"] : ""
  end

  def get_inferred_answers(case_log)
    return enabled_inferred_answers(inferred_answers, case_log).keys.map { |x| case_log[x].to_s } if inferred_answers

    []
  end

  def read_only?
    !!readonly
  end

  def enabled?(case_log)
    return true if conditional_on.blank?

    conditional_on.map { |condition| evaluate_condition(condition, case_log) }.all?
  end

  def hidden_in_check_answers?
    hidden_in_check_answers
  end

  def has_inferred_check_answers_value?(case_log)
    return inferred_check_answers_value["condition"].values[0] == case_log[inferred_check_answers_value["condition"].keys[0]] if inferred_check_answers_value.present?

    false
  end

  def update_answer_link_name(case_log)
    link_type = if type == "checkbox"
                  answer_options.keys.any? { |key| case_log[key] == "Yes" } ? "Change" : "Answer"
                else
                  case_log[id].blank? ? "Answer" : "Change"
                end
    "#{link_type}<span class=\"govuk-visually-hidden\"> #{check_answer_label.to_s.downcase}</span>".html_safe
  end

  def completed?(case_log)
    # Special case as No is a valid answer but doesn't let you progress and use the service
    return false if id == "gdpr_acceptance" && case_log[id] == "No"

    case_log[id].present? || !case_log.respond_to?(id.to_sym)
  end

private

  def checkbox_answer_label(case_log)
    answer = []
    answer_options.each { |key, value| case_log[key] == "Yes" ? answer << value : nil }
    answer.join(", ")
  end

  def conditional_on
    @conditional_on ||= form.conditional_question_conditions.select do |condition|
      condition[:to] == id
    end
  end

  def evaluate_condition(condition, case_log)
    case page.questions.find { |q| q.id == condition[:from] }.type
    when "numeric"
      operator = condition[:cond][/[<>=]+/].to_sym
      operand = condition[:cond][/\d+/].to_i
      case_log[condition[:from]].present? && case_log[condition[:from]].send(operator, operand)
    when "text", "radio", "select"
      case_log[condition[:from]].present? && condition[:cond].include?(case_log[condition[:from]])
    else
      raise "Not implemented yet"
    end
  end

  def enabled_inferred_answers(inferred_answers, case_log)
    inferred_answers.filter { |_key, value| value.all? { |condition_key, condition_value| case_log[condition_key] == condition_value } }
  end
end
