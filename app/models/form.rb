class Form
  attr_reader :form_definition, :sections, :subsections, :pages, :questions

  def initialize(form_path)
    raise "No form definition file exists for given year".freeze unless File.exist?(form_path)

    @form_definition = JSON.parse(File.open(form_path).read)
    @sections = form_definition["sections"].map { |id, s| Form::Section.new(id, s, self) }
    @subsections = sections.flat_map(&:subsections)
    @pages = subsections.flat_map(&:pages)
    @questions = pages.flat_map(&:questions)
  end

  def get_subsection(id)
    subsections.find { |s| s.id == id }
  end

  def get_page(id)
    pages.find { |p| p.id == id }
  end

  def subsection_for_page(page)
    subsections.find { |s| s.pages.find { |p| p.id == page.id } }
  end

  def next_page(page, case_log)
    page_ids = subsection_for_page(page).pages.map(&:id)
    page_idx = page_ids.index(page.id)
    nxt_page = get_page(page_ids[page_idx + 1])
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

  def conditional_question_conditions
    conditions = questions.map { |q| Hash(q.id => q.conditional_for) if q.conditional_for.present? }.compact
    conditions.map { |c|
      c.map { |k, v| v.keys.map { |key| Hash(from: k, to: key, cond: v[key]) } }
    }.flatten
  end
end
