class Form
  attr_reader :form_definition

  def initialize(form_path)
    raise "No form definition file exists for given year".freeze unless File.exist?(form_path)

    @form_definition = JSON.parse(File.open(form_path).read)
  end

  # Returns a hash with sections as keys
  def all_sections
    @all_sections ||= @form_definition["sections"]
  end

  # Returns a hash with subsections as keys
  def all_subsections
    @all_subsections ||= all_sections.map { |_section_key, section_value|
      section_value["subsections"]
    }.reduce(:merge)
  end

  # Returns a hash with pages as keys
  def all_pages
    @all_pages ||= all_subsections.map { |_subsection_key, subsection_value|
      subsection_value["pages"]
    }.reduce(:merge)
  end

  # Returns a hash with the pages of a subsection as keys
  def pages_for_subsection(subsection)
    all_subsections[subsection]["pages"]
  end

  # Returns a hash with the questions as keys
  def questions_for_page(page)
    all_pages[page]["questions"]
  end

  # Returns a hash with the questions as keys
  def questions_for_subsection(subsection)
    pages_for_subsection(subsection).map { |title, _value| questions_for_page(title) }.reduce(:merge)
  end

  # Returns a hash with soft validation questions as keys
  def soft_validations_for_page(page)
    all_pages[page]["soft_validations"]
  end

  def expected_responses_for_page(page)
    questions_for_page(page).merge(soft_validations_for_page(page) || {})
  end

  def first_page_for_subsection(subsection)
    pages_for_subsection(subsection).keys.first
  end

  def subsection_for_page(page)
    all_subsections.find { |_subsection_key, subsection_value|
      subsection_value["pages"].key?(page)
    }.first
  end

  def page_for_question(question)
    all_pages.find { |_page_key, page_value| page_value["questions"].key?(question) }.first
  end

  def next_page(page, case_log)
    subsection = subsection_for_page(page)
    page_idx = pages_for_subsection(subsection).keys.index(page)
    nxt_page = pages_for_subsection(subsection).keys[page_idx + 1]
    return :check_answers if nxt_page.nil?
    return nxt_page if page_routed_to?(nxt_page, case_log)

    next_page(nxt_page, case_log)
  end

  def next_page_redirect_path(page, case_log)
    nxt_page = next_page(page, case_log)
    if nxt_page == :check_answers
      subsection = subsection_for_page(page)
      "case_log_#{subsection}_check_answers_path"
    else
      "case_log_#{nxt_page}_path"
    end
  end

  def all_questions
    @all_questions ||= all_pages.map { |_page_key, page_value|
      page_value["questions"]
    }.reduce(:merge)
  end

  def filter_conditional_questions(questions, case_log)
    applicable_questions = questions

    questions.each do |k, question|
      unless page_routed_to?(page_for_question(k), case_log)
        applicable_questions = applicable_questions.reject { |z| z == k }
      end

      question.fetch("conditional_for", []).each do |conditional_question_key, condition|
        if condition_not_met(case_log, k, question, condition)
          applicable_questions = applicable_questions.reject { |z| z == conditional_question_key }
        end
      end
    end
    applicable_questions
  end

  def page_routed_to?(page, case_log)
    return true unless (conditions = page_dependencies(page))

    conditions.all? do |question, value|
      case_log[question].present? && case_log[question] == value
    end
  end

  def page_dependencies(page)
    all_pages[page]["depends_on"]
  end

  def condition_not_met(case_log, question_key, question, condition)
    case question["type"]
    when "numeric"
      operator = condition[/[<>=]+/].to_sym
      operand = condition[/\d+/].to_i
      case_log[question_key].blank? || !case_log[question_key].send(operator, operand)
    when "text"
      case_log[question_key].blank? || !condition.include?(case_log[question_key])
    when "radio"
      case_log[question_key].blank? || !condition.include?(case_log[question_key])
    when "select"
      case_log[question_key].blank? || !condition.include?(case_log[question_key])
    else
      raise "Not implemented yet"
    end
  end

  def get_answer_label(case_log, question_title)
    question = all_questions[question_title]
    if question["type"] == "checkbox"
      answer = []
      question["answer_options"].each { |key, value| case_log[key] == "Yes" ? answer << value : nil }
      return answer.join(", ")
    end

    case_log[question_title]
  end
end
