class Form::Subsection
  attr_accessor :id, :label, :section, :pages, :depends_on, :form

  def initialize(id, hsh, section)
    @id = id
    @section = section
    if hsh
      @label = hsh["label"]
      @depends_on = hsh["depends_on"]
      @pages = hsh["pages"].map { |s_id, p| Form::Page.new(s_id, p, self) }
    end
  end

  delegate :form, to: :section

  def questions
    @questions ||= pages.flat_map(&:questions)
  end

  def enabled?(case_log)
    return true unless depends_on

    depends_on.any? do |conditions_set|
      conditions_set.all? do |subsection_id, dependent_status|
        form.get_subsection(subsection_id).status(case_log) == dependent_status.to_sym
      end
    end
  end

  def status(case_log)
    unless enabled?(case_log)
      return :cannot_start_yet
    end

    qs = applicable_questions(case_log)
    qs_optional_removed = qs.reject { |q| case_log.optional_fields.include?(q.id) }
    return :not_started if qs.all? { |question| case_log[question.id].blank? || question.read_only? }
    return :completed if qs_optional_removed.all? { |question| question.completed?(case_log) }

    :in_progress
  end

  def is_incomplete?(case_log)
    %i[not_started in_progress].include?(status(case_log))
  end

  def is_started?(case_log)
    %i[in_progress completed].include?(status(case_log))
  end

  def applicable_questions(case_log)
    questions.select do |q|
      (q.displayed_to_user?(case_log) && !q.derived?) || q.has_inferred_check_answers_value?(case_log)
    end
  end
end
