class Form
  attr_reader :form_definition, :sections, :subsections, :pages, :questions,
              :start_date, :end_date, :type, :name, :setup_definition,
              :setup_sections, :form_sections, :unresolved_log_redirect_page_id

  def initialize(form_path, start_year = "", sections_in_form = [], type = "lettings")
    if type == "sales"
      @setup_sections = [Form::Sales::Sections::Setup.new(nil, nil, self)]
      @form_sections = sections_in_form.map { |sec| sec.new(nil, nil, self) }
      @type = "sales"
      @sections = setup_sections + form_sections
      @subsections = sections.flat_map(&:subsections)
      @pages = subsections.flat_map(&:pages)
      @questions = pages.flat_map(&:questions)
      @start_date = Time.zone.local(start_year, 4, 1)
      @end_date = Time.zone.local(start_year + 1, 7, 1)
      @form_definition = {
        "form_type" => type,
        "start_date" => start_date,
        "end_date" => end_date,
        "sections" => sections,
      }
    else
      raise "No form definition file exists for given year".freeze unless File.exist?(form_path)

      @setup_sections = [Form::Lettings::Sections::Setup.new(nil, nil, self)]
      @form_definition = JSON.parse(File.open(form_path).read)
      @form_sections = form_definition["sections"].map { |id, s| Form::Section.new(id, s, self) }
      @type = form_definition["form_type"]
      @sections =  setup_sections + form_sections
      @subsections = sections.flat_map(&:subsections)
      @pages = subsections.flat_map(&:pages)
      @questions = pages.flat_map(&:questions)
      @start_date = Time.iso8601(form_definition["start_date"])
      @end_date = Time.iso8601(form_definition["end_date"])
      @unresolved_log_redirect_page_id = form_definition["unresolved_log_redirect_page_id"]
    end
    @name = "#{start_date.year}_#{end_date.year}_#{type}"
  end

  def get_subsection(id)
    subsections.find { |s| s.id == id.to_s.underscore }
  end

  def get_page(id)
    pages.find { |p| p.id == id.to_s.underscore }
  end

  def get_question(id, log, current_user = nil)
    all_questions = questions.select { |q| q.id == id.to_s.underscore }
    routed_question = all_questions.find { |q| q.page.routed_to?(log, current_user) } if log
    routed_question || all_questions[0]
  end

  def subsection_for_page(page)
    subsections.find { |s| s.pages.find { |p| p.id == page.id } }
  end

  def next_page(page, log, current_user)
    return page.next_unresolved_page_id || :check_answers if log.unresolved

    page_ids = subsection_for_page(page).pages.map(&:id)
    page_index = page_ids.index(page.id)
    page_id = if page.id.include?("value_check") && log[page.questions[0].id] == 1 && page.routed_to?(log, current_user)
                previous_page(page_ids, page_index, log, current_user)
              else
                page_ids[page_index + 1]
              end
    nxt_page = get_page(page_id)

    return :check_answers if nxt_page.nil?
    return nxt_page.id if nxt_page.routed_to?(log, current_user)

    next_page(nxt_page, log, current_user)
  end

  def next_page_redirect_path(page, log, current_user)
    nxt_page = next_page(page, log, current_user)
    if nxt_page == :check_answers
      "#{type}_log_#{subsection_for_page(page).id}_check_answers_path"
    else
      "#{type}_log_#{nxt_page}_path"
    end
  end

  def cancel_path(page, log)
    "#{log.class.name.underscore}_#{page.subsection.id}_check_answers_path"
  end

  def unresolved_log_path
    "#{type}_log_#{unresolved_log_redirect_page_id}_path"
  end

  def next_incomplete_section_redirect_path(subsection, log)
    subsection_ids = subsections.map(&:id)

    if log.status == "completed"
      return first_question_in_last_subsection(subsection_ids)
    end

    next_subsection = next_subsection(subsection, log, subsection_ids)

    case next_subsection.status(log)
    when :completed
      next_incomplete_section_redirect_path(next_subsection, log)
    when :in_progress
      "#{next_subsection.id}/check_answers".dasherize
    when :not_started
      first_question_in_subsection = next_subsection.pages.find { |page| page.routed_to?(log, nil) }.id
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

  def next_subsection(subsection, log, subsection_ids)
    next_subsection_id_index = subsection_ids.index(subsection.id) + 1
    next_subsection = get_subsection(subsection_ids[next_subsection_id_index])

    if subsection_ids[subsection_ids.length - 1] == subsection.id && log.status != "completed"
      next_subsection = get_subsection(subsection_ids[0])
    end

    next_subsection
  end

  def all_subsections_except_declaration_completed?(log)
    subsection_ids = subsections.map(&:id)
    subsection_ids.delete_at(subsection_ids.length - 1)
    return true if subsection_ids.all? { |subsection_id| get_subsection(subsection_id).status(log) == :completed }

    false
  end

  def conditional_question_conditions
    conditions = questions.map { |q| Hash(q.id => q.conditional_for) if q.conditional_for.present? }.compact
    conditions.map { |c|
      c.map { |k, v| v.keys.map { |key| Hash(from: k, to: key, cond: v[key]) } }
    }.flatten
  end

  def invalidated_pages(log, current_user = nil)
    pages.reject { |p| p.routed_to?(log, current_user) }
  end

  def invalidated_questions(log)
    invalidated_page_questions(log) + invalidated_conditional_questions(log)
  end

  def invalidated_page_questions(log, current_user = nil)
    # we're already treating these fields as a special case and reset their values upon saving a log
    callback_questions = %w[postcode_known la ppcodenk previous_la_known prevloc postcode_full ppostcode_full location_id]
    questions.reject { |q| q.page.routed_to?(log, current_user) || q.derived? || callback_questions.include?(q.id) } || []
  end

  def reset_not_routed_questions(log)
    enabled_questions = enabled_page_questions(log)
    enabled_question_ids = enabled_questions.map(&:id)

    invalidated_page_questions(log).each do |question|
      if %w[radio checkbox].include?(question.type)
        enabled_answer_options = enabled_question_ids.include?(question.id) ? enabled_questions.find { |q| q.id == question.id }.answer_options : {}
        current_answer_option_valid = enabled_answer_options.present? ? enabled_answer_options.key?(log.public_send(question.id).to_s) : false

        if !current_answer_option_valid && log.respond_to?(question.id.to_s)
          Rails.logger.debug("Cleared #{question.id} value")
          log.public_send("#{question.id}=", nil)
        else

          (question.answer_options.keys - enabled_answer_options.keys).map do |invalid_answer_option|
            Rails.logger.debug("Cleared #{invalid_answer_option} value")
            log.public_send("#{invalid_answer_option}=", nil) if log.respond_to?(invalid_answer_option)
          end
        end
      else
        Rails.logger.debug("Cleared #{question.id} value")
        log.public_send("#{question.id}=", nil) unless enabled_question_ids.include?(question.id)
      end
    end
  end

  def enabled_page_questions(log)
    questions - invalidated_page_questions(log)
  end

  def invalidated_conditional_questions(log)
    questions.reject { |q| q.enabled?(log) } || []
  end

  def readonly_questions
    questions.select(&:read_only?)
  end

  def numeric_questions
    questions.select { |q| q.type == "numeric" }
  end

  def previous_page(page_ids, page_index, log, current_user)
    prev_page = get_page(page_ids[page_index - 1])
    return prev_page.id if prev_page.routed_to?(log, current_user)

    previous_page(page_ids, page_index - 1, log, current_user)
  end

  def send_chain(arr, log)
    Array(arr).inject(log) { |o, a| o.public_send(*a) }
  end

  def depends_on_met(depends_on, log)
    return true unless depends_on

    depends_on.any? do |conditions_set|
      return false unless conditions_set

      conditions_set.all? do |question, value|
        if value.is_a?(Hash) && value.key?("operator")
          operator = value["operator"]
          operand = value["operand"]
          log[question]&.send(operator, operand)
        else
          parts = question.split(".")
          log_value = send_chain(parts, log)

          value.nil? ? log_value == value : !log_value.nil? && log_value == value
        end
      end
    end
  end

  def inspect
    "#<#{self.class} @type=#{type} @name=#{name}>"
  end
end
