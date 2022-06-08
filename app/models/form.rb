class Form
  attr_reader :form_definition, :sections, :subsections, :pages, :questions,
              :start_date, :end_date, :type, :name

  def initialize(form_path, name)
    raise "No form definition file exists for given year".freeze unless File.exist?(form_path)

    @form_definition = JSON.parse(File.open(form_path).read)
    @name = name
    @start_date = Time.iso8601(form_definition["start_date"])
    @end_date = Time.iso8601(form_definition["end_date"])
    @type = form_definition["form_type"]
    @sections = form_definition["sections"].map { |id, s| Form::Section.new(id, s, self) }
    @subsections = sections.flat_map(&:subsections)
    @pages = subsections.flat_map(&:pages)
    @questions = pages.flat_map(&:questions)
  end

  def get_subsection(id)
    subsections.find { |s| s.id == id.to_s.underscore }
  end

  def get_page(id)
    pages.find { |p| p.id == id.to_s.underscore }
  end

  def get_question(id, case_log)
    all_questions = questions.select { |q| q.id == id.to_s.underscore }
    routed_question = all_questions.find { |q| q.page.routed_to?(case_log) } if case_log
    routed_question || all_questions[0]
  end

  def subsection_for_page(page)
    subsections.find { |s| s.pages.find { |p| p.id == page.id } }
  end

  def next_page(page, case_log)
    page_ids = subsection_for_page(page).pages.map(&:id)
    page_index = page_ids.index(page.id)
    page_id = page.id.include?("value_check") && case_log[page.questions[0].id] == 1 && page.routed_to?(case_log) ? previous_page(page_ids, page_index, case_log) : page_ids[page_index + 1]
    nxt_page = get_page(page_id)

    return :check_answers if nxt_page.nil?
    return nxt_page.id if nxt_page.routed_to?(case_log)

    next_page(nxt_page, case_log)
  end

  def next_page_redirect_path(page, case_log)
    nxt_page = next_page(page, case_log)
    if nxt_page == :check_answers
      "case_log_#{subsection_for_page(page).id}_check_answers_path"
    else
      "case_log_#{nxt_page}_path"
    end
  end

  def next_incomplete_section_redirect_path(subsection, case_log)
    subsection_ids = subsections.map(&:id)

    if case_log.status == "completed"
      return first_question_in_last_subsection(subsection_ids)
    end

    next_subsection = next_subsection(subsection, case_log, subsection_ids)

    case next_subsection.status(case_log)
    when :completed
      next_incomplete_section_redirect_path(next_subsection, case_log)
    when :in_progress
      "#{next_subsection.id}/check_answers".dasherize
    when :not_started
      first_question_in_subsection = next_subsection.pages.first.id
      first_question_in_subsection.to_s.dasherize
    else
      "error"
    end
  end

  def first_question_in_last_subsection(subsection_ids)
    next_subsection = get_subsection(subsection_ids[subsection_ids.length - 1])
    first_question_in_subsection = next_subsection.pages.first.id
    first_question_in_subsection.to_s.dasherize
  end

  def next_subsection(subsection, case_log, subsection_ids)
    next_subsection_id_index = subsection_ids.index(subsection.id) + 1
    next_subsection = get_subsection(subsection_ids[next_subsection_id_index])

    if subsection_ids[subsection_ids.length - 1] == subsection.id && case_log.status != "completed"
      next_subsection = get_subsection(subsection_ids[0])
    end

    next_subsection
  end

  def all_subsections_except_declaration_completed?(case_log)
    subsection_ids = subsections.map(&:id)
    subsection_ids.delete_at(subsection_ids.length - 1)
    return true if subsection_ids.all? { |subsection_id| get_subsection(subsection_id).status(case_log) == :completed }

    false
  end

  def conditional_question_conditions
    conditions = questions.map { |q| Hash(q.id => q.conditional_for) if q.conditional_for.present? }.compact
    conditions.map { |c|
      c.map { |k, v| v.keys.map { |key| Hash(from: k, to: key, cond: v[key]) } }
    }.flatten
  end

  def invalidated_pages(case_log)
    pages.reject { |p| p.routed_to?(case_log) }
  end

  def invalidated_questions(case_log)
    invalidated_page_questions(case_log) + invalidated_conditional_questions(case_log)
  end

  def invalidated_page_questions(case_log)
    # we're already treating address fields as a special case and reset their values upon saving a case_log
    address_questions = %w[postcode_known la previous_postcode_known previous_la_known prevloc postcode_full ppostcode_full]
    invalidated_pages(case_log).flat_map(&:questions).reject { |q| address_questions.include?(q.id) } || []
  end

  def enabled_page_questions(case_log)
    pages_that_are_routed_to_or_derived = pages.select { |p| p.routed_to?(case_log) || p.derived }
    pages_that_are_routed_to_or_derived.flat_map(&:questions) || []
  end

  def invalidated_conditional_questions(case_log)
    questions.reject { |q| q.enabled?(case_log) } || []
  end

  def readonly_questions
    questions.select(&:read_only?)
  end

  def numeric_questions
    questions.select { |q| q.type == "numeric" }
  end

  def previous_page(page_ids, page_index, case_log)
    prev_page = get_page(page_ids[page_index - 1])
    return prev_page.id if prev_page.routed_to?(case_log)

    previous_page(page_ids, page_index - 1, case_log)
  end

  def send_chain(arr, case_log)
    Array(arr).inject(case_log) { |o, a| o.public_send(*a) }
  end

  def depends_on_met(depends_on, case_log)
    return true unless depends_on

    depends_on.any? do |conditions_set|
      return false unless conditions_set

      conditions_set.all? do |x|

        object = x["object"]
        method = x["method"]
        value = x["value"]
        if value.is_a?(Hash) && value.key?("operator")
          operator = value["operator"]
          operand = value["operand"]
          case_log[method]&.send(operator, operand)
        else
          parts = method.split(".")

          case_log_value = send_chain(parts, case_log)

          value.nil? ? case_log_value == value : !case_log_value.nil? && case_log_value == value
        end 
      end
    end
  end
end
