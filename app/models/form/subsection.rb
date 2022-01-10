class Form::Subsection
  attr_accessor :id, :label, :section, :pages, :depends_on, :form

  def initialize(id, hsh, section)
    @id = id
    @label = hsh["label"]
    @depends_on = hsh["depends_on"]
    @pages = hsh["pages"].map { |s_id, p| Form::Page.new(s_id, p, self) }
    @section = section
  end

  delegate :form, to: :section

  def questions
    @questions ||= pages.flat_map(&:questions)
  end

  def enabled?(case_log)
    return true unless depends_on

    depends_on.all? do |subsection_id, dependent_status|
      form.get_subsection(subsection_id).status(case_log) == dependent_status.to_sym
    end
  end

  def status(case_log)
    unless enabled?(case_log)
      return :cannot_start_yet
    end

    qs = applicable_questions(case_log)
    return :not_started if qs.all? { |question| case_log[question.id].blank? }
    return :completed if qs.all? { |question| question.completed?(case_log) }

    :in_progress
  end

  def is_incomplete?(case_log)
    %i[not_started in_progress].include?(status(case_log))
  end

  def is_started?(case_log)
    %i[in_progress completed].include?(status(case_log))
  end

  def applicable_questions_count(case_log)
    applicable_questions(case_log).count
  end

  def answered_questions_count(case_log)
    answered_questions(case_log).count
  end

  def applicable_questions(case_log)
    questions.select { |q| (displayed_to_user?(case_log, q) && !q.hidden_in_check_answers?) || q.has_inferred_check_answers_value?(case_log) }
  end

  def answered_questions(case_log)
    applicable_questions(case_log).select { |question| case_log[question.id].present? }
  end

  def unanswered_questions(case_log)
    applicable_questions(case_log) - answered_questions(case_log)
  end

  def displayed_to_user?(case_log, question)
    question.page.routed_to?(case_log) && question.enabled?(case_log) && !question.read_only?
  end
end
