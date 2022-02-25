class Form::Question
  attr_accessor :id, :header, :hint_text, :description, :questions,
                :type, :min, :max, :step, :width, :fields_to_add, :result_field,
                :conditional_for, :readonly, :answer_options, :page, :check_answer_label,
                :inferred_answers, :hidden_in_check_answers, :inferred_check_answers_value,
                :guidance_partial, :prefix, :suffix, :requires_js, :fields_added

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
    @fields_added = hsh["fields_added"]
    @page = page
  end

  delegate :subsection, to: :page
  delegate :form, to: :subsection

  def answer_label(case_log)
    return checkbox_answer_label(case_log) if type == "checkbox"
    return case_log[id]&.to_formatted_s(:govuk_date).to_s if type == "date"

    answer = label_from_value(case_log[id]) if case_log[id].present?
    answer_label = [prefix, format_value(answer), suffix_label(case_log)].join("") if answer
    return answer_label if answer_label

    has_inferred_check_answers_value?(case_log) ? inferred_check_answers_value["value"] : ""
  end

  def get_inferred_answers(case_log)
    return [] unless inferred_answers

    enabled_inferred_answers(inferred_answers, case_log).keys.map do |x|
      form.get_question(x).label_from_value(case_log[x])
    end
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
                  answer_options.keys.any? { |key| value_is_yes?(case_log[key]) } ? "Change" : "Answer"
                else
                  case_log[id].blank? ? "Answer" : "Change"
                end
    "#{link_type}<span class=\"govuk-visually-hidden\"> #{check_answer_label.to_s.downcase}</span>".html_safe
  end

  def completed?(case_log)
    return answer_options.keys.any? { |key| value_is_yes?(case_log[key]) } if type == "checkbox"

    case_log[id].present? || !case_log.respond_to?(id.to_sym) || has_inferred_display_value?(case_log)
  end

  def value_from_label(label)
    return unless label

    case type
    when "radio"
      answer_options.find { |opt| opt.second["value"] == label.to_s }.first
    when "select"
      answer_options.find { |opt| opt.second == label.to_s }.first
    else
      label
    end
  end

  def label_from_value(value)
    return unless value

    case type
    when "radio"
      answer_options[value.to_s]["value"]
    when "select"
      answer_options[value.to_s]
    else
      value.to_s
    end
  end

  def value_is_yes?(value)
    case type
    when "checkbox"
      value == 1
    when "radio"
      RADIO_YES_VALUE[id.to_sym]&.include?(value)
    else
      value.downcase == "yes"
    end
  end

  def value_is_no?(value)
    case type
    when "checkbox"
      value && value.zero?
    when "radio"
      RADIO_NO_VALUE[id.to_sym]&.include?(value)
    else
      value.downcase == "no"
    end
  end

  def value_is_dont_know?(value)
    type == "radio" && RADIO_DONT_KNOW_VALUE[id.to_sym]&.include?(value)
  end

  def value_is_refused?(value)
    type == "radio" && RADIO_REFUSED_VALUE[id.to_sym]&.include?(value)
  end

private

  def has_inferred_display_value?(case_log)
    inferred_check_answers_value.present? && case_log[inferred_check_answers_value["condition"].keys.first] == inferred_check_answers_value["condition"].values.first
  end

  def checkbox_answer_label(case_log)
    answer = []
    answer_options.each { |key, options| value_is_yes?(case_log[key]) ? answer << options["value"] : nil }
    answer.join(", ")
  end

  def format_value(answer_label)
    prefix == "£" ? ActionController::Base.helpers.number_to_currency(answer_label, delimiter: ",", format: "%n") : answer_label
  end

  def suffix_label(case_log)
    return "" unless suffix
    return suffix if suffix.is_a?(String)

    label = ""

    suffix.each do |s|
      condition = s["depends_on"]
      next unless condition

      answer = case_log.send(condition.keys.first)
      if answer == condition.values.first
        label = ANSWER_SUFFIX_LABELS.key?(answer) ? ANSWER_SUFFIX_LABELS[answer] : answer
      end
    end
    label
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

  ANSWER_SUFFIX_LABELS = {
    0 => " every week",
    1 => " every month",
    2 => " every year",
  }.freeze

  RADIO_YES_VALUE = {
    renewal: [1],
    postcode_known: [1],
    previous_postcode_known: [1],
    la_known: [1],
    previous_la_known: [1],
    first_time_property_let_as_social_housing: [1],
    wchair: [1],
    majorrepairs: [1],
    startertenancy: [0],
    letting_in_sheltered_accommodation: [0, 1],
    armedforces: [0, 1, 2],
    leftreg: [0],
    reservist: [0],
    preg_occ: [0],
    illness: [0],
    underoccupation_benefitcap: [0, 1, 2],
    reasonpref: [0],
    net_income_known: [0],
    household_charge: [0],
    is_carehome: [1],
    rent_shortfall: [0],
  }.freeze

  RADIO_NO_VALUE = {
    renewal: [0],
    postcode_known: [0],
    previous_postcode_known: [0],
    la_known: [0],
    previous_la_known: [0],
    first_time_property_let_as_social_housing: [0],
    wchair: [0],
    majorrepairs: [0],
    startertenancy: [1],
    letting_in_sheltered_accommodation: [2],
    armedforces: [3],
    leftreg: [1],
    reservist: [1],
    preg_occ: [1],
    illness: [1],
    underoccupation_benefitcap: [3],
    reasonpref: [1],
    net_income_known: [1],
    household_charge: [1],
    is_carehome: [0],
    rent_shortfall: [1],
  }.freeze

  RADIO_DONT_KNOW_VALUE = {
    letting_in_sheltered_accommodation: [3],
    underoccupation_benefitcap: [4],
    reasonpref: [2],
    rent_shortfall: [1],
    layear: [7],
    reason_for_leaving_last_settled_home: [32],
    hb: [5],
    benefits: [3],
    unitletas: [3],
  }.freeze

  RADIO_REFUSED_VALUE = {
    sex1: %w[R],
    sex2: %w[R],
    sex3: %w[R],
    sex4: %w[R],
    sex5: %w[R],
    sex6: %w[R],
    sex7: %w[R],
    sex8: %w[R],
    relat2: [3],
    relat3: [3],
    relat4: [3],
    relat5: [3],
    relat6: [3],
    relat7: [3],
    relat8: [3],
    ecstat1: [10],
    ecstat2: [10],
    ecstat3: [10],
    ecstat4: [10],
    ecstat5: [10],
    ecstat6: [10],
    ecstat7: [10],
    ecstat8: [10],
    letting_in_sheltered_accommodation: [3],
    armedforces: [4],
    leftreg: [3],
    reservist: [2],
    preg_occ: [2],
    illness: [2],
    hb: [6],
  }.freeze
end
