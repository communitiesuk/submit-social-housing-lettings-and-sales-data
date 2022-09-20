class Form
  attr_reader :form_definition, :sections, :subsections, :pages, :questions,
              :start_date, :end_date, :type, :name, :setup_definition,
              :setup_sections, :form_sections

  include Form::Setup

  def initialize(form_path, name)
    raise "No form definition file exists for given year".freeze unless File.exist?(form_path)

    @name = name
    @setup_sections = [Form::Setup::Sections::Setup.new(nil, nil, self)]
    @form_definition = JSON.parse(File.open(form_path).read)
    @form_sections = form_definition["sections"].map { |id, s| Form::Section.new(id, s, self) }
    @type = form_definition["form_type"]
    @sections =  setup_sections + form_sections
    @subsections = sections.flat_map(&:subsections)
    @pages = subsections.flat_map(&:pages)
    @questions = pages.flat_map(&:questions)
    @start_date = Time.iso8601(form_definition["start_date"])
    @end_date = Time.iso8601(form_definition["end_date"])
  end

  def get_subsection(id)
    subsections.find { |s| s.id == id.to_s.underscore }
  end

  def get_page(id)
    pages.find { |p| p.id == id.to_s.underscore }
  end

  def get_question(id, lettings_log, current_user = nil)
    all_questions = questions.select { |q| q.id == id.to_s.underscore }
    routed_question = all_questions.find { |q| q.page.routed_to?(lettings_log, current_user) } if lettings_log
    routed_question || all_questions[0]
  end

  def subsection_for_page(page)
    subsections.find { |s| s.pages.find { |p| p.id == page.id } }
  end

  def next_page(page, lettings_log, current_user)
    page_ids = subsection_for_page(page).pages.map(&:id)
    page_index = page_ids.index(page.id)
    page_id = if page.id.include?("value_check") && lettings_log[page.questions[0].id] == 1 && page.routed_to?(lettings_log, current_user)
                previous_page(page_ids, page_index, lettings_log, current_user)
              else
                page_ids[page_index + 1]
              end
    nxt_page = get_page(page_id)

    return :check_answers if nxt_page.nil?
    return nxt_page.id if nxt_page.routed_to?(lettings_log, current_user)

    next_page(nxt_page, lettings_log, current_user)
  end

  def next_page_redirect_path(page, lettings_log, current_user)
    nxt_page = next_page(page, lettings_log, current_user)
    if nxt_page == :check_answers
      "lettings_log_#{subsection_for_page(page).id}_check_answers_path"
    else
      "lettings_log_#{nxt_page}_path"
    end
  end

  def next_incomplete_section_redirect_path(subsection, lettings_log)
    subsection_ids = subsections.map(&:id)

    if lettings_log.status == "completed"
      return first_question_in_last_subsection(subsection_ids)
    end

    next_subsection = next_subsection(subsection, lettings_log, subsection_ids)

    case next_subsection.status(lettings_log)
    when :completed
      next_incomplete_section_redirect_path(next_subsection, lettings_log)
    when :in_progress
      "#{next_subsection.id}/check_answers".dasherize
    when :not_started
      first_question_in_subsection = next_subsection.pages.find { |page| page.routed_to?(lettings_log, nil) }.id
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

  def next_subsection(subsection, lettings_log, subsection_ids)
    next_subsection_id_index = subsection_ids.index(subsection.id) + 1
    next_subsection = get_subsection(subsection_ids[next_subsection_id_index])

    if subsection_ids[subsection_ids.length - 1] == subsection.id && lettings_log.status != "completed"
      next_subsection = get_subsection(subsection_ids[0])
    end

    next_subsection
  end

  def all_subsections_except_declaration_completed?(lettings_log)
    subsection_ids = subsections.map(&:id)
    subsection_ids.delete_at(subsection_ids.length - 1)
    return true if subsection_ids.all? { |subsection_id| get_subsection(subsection_id).status(lettings_log) == :completed }

    false
  end

  def conditional_question_conditions
    conditions = questions.map { |q| Hash(q.id => q.conditional_for) if q.conditional_for.present? }.compact
    conditions.map { |c|
      c.map { |k, v| v.keys.map { |key| Hash(from: k, to: key, cond: v[key]) } }
    }.flatten
  end

  def invalidated_pages(lettings_log, current_user = nil)
    pages.reject { |p| p.routed_to?(lettings_log, current_user) }
  end

  def invalidated_questions(lettings_log)
    invalidated_page_questions(lettings_log) + invalidated_conditional_questions(lettings_log)
  end

  def invalidated_page_questions(lettings_log, current_user = nil)
    # we're already treating these fields as a special case and reset their values upon saving a lettings_log
    callback_questions = %w[postcode_known la ppcodenk previous_la_known prevloc postcode_full ppostcode_full location_id]
    questions.reject { |q| q.page.routed_to?(lettings_log, current_user) || q.derived? || callback_questions.include?(q.id) } || []
  end

  def enabled_page_questions(lettings_log)
    questions - invalidated_page_questions(lettings_log)
  end

  def invalidated_conditional_questions(lettings_log)
    questions.reject { |q| q.enabled?(lettings_log) } || []
  end

  def readonly_questions
    questions.select(&:read_only?)
  end

  def numeric_questions
    questions.select { |q| q.type == "numeric" }
  end

  def previous_page(page_ids, page_index, lettings_log, current_user)
    prev_page = get_page(page_ids[page_index - 1])
    return prev_page.id if prev_page.routed_to?(lettings_log, current_user)

    previous_page(page_ids, page_index - 1, lettings_log, current_user)
  end

  def send_chain(arr, lettings_log)
    Array(arr).inject(lettings_log) { |o, a| o.public_send(*a) }
  end

  def depends_on_met(depends_on, lettings_log)
    return true unless depends_on

    depends_on.any? do |conditions_set|
      return false unless conditions_set

      conditions_set.all? do |question, value|
        if value.is_a?(Hash) && value.key?("operator")
          operator = value["operator"]
          operand = value["operand"]
          lettings_log[question]&.send(operator, operand)
        else
          parts = question.split(".")
          lettings_log_value = send_chain(parts, lettings_log)

          value.nil? ? lettings_log_value == value : !lettings_log_value.nil? && lettings_log_value == value
        end
      end
    end
  end
end
