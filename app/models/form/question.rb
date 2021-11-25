class Form::Question
  attr_accessor :id, :header, :hint_text, :description, :questions,
                :type, :min, :max, :step, :fields_to_add, :result_field,
                :conditional_for, :readonly, :answer_options, :page, :check_answer_label

  def initialize(id, hsh, page)
    @id = id
    @check_answer_label = hsh["check_answer_label"]
    @header = hsh["header"]
    @hint_text = hsh["hint_text"]
    @type = hsh["type"]
    @min = hsh["min"]
    @max = hsh["max"]
    @step = hsh["step"]
    @fields_to_add = hsh["fields-to-add"]
    @result_field = hsh["result-field"]
    @readonly = hsh["readonly"]
    @answer_options = hsh["answer_options"]
    @conditional_for = hsh["conditional_for"]
    @page = page
  end

  delegate :subsection, to: :page
  delegate :form, to: :subsection

  def answer_label(case_log)
    return checkbox_answer_label(case_log) if type == "checkbox"

    case_log[id].to_s
  end

  def read_only?
    !!readonly
  end

  def enabled?(case_log)
    return true if conditional_on.blank?

    conditional_on.map { |condition| evaluate_condition(condition, case_log) }.all?
  end

  def update_answer_link_name(case_log)
    if type == "checkbox"
      answer_options.keys.any? { |key| case_log[key] == "Yes" } ? "Change" : "Answer"
    else
      case_log[id].blank? ? "Answer" : "Change"
    end
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
end
