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

  def enabled?(log)
    return true unless depends_on

    form.depends_on_met(depends_on, log)
  end

  def status(log)
    return :cannot_start_yet unless enabled?(log)

    qs = applicable_questions(log)
    qs_optional_removed = qs.reject { |q| log.optional_fields.include?(q.id) }
    return :not_started if qs.count.positive? && qs.all? { |question| question.unanswered?(log) || question.read_only? || question.derived? }
    return :completed if qs_optional_removed.all? { |question| question.completed?(log) }

    :in_progress
  end

  def is_incomplete?(log)
    %i[not_started in_progress].include?(status(log))
  end

  def is_started?(log)
    %i[in_progress completed].include?(status(log))
  end

  def applicable_questions(log)
    questions.select do |q|
      (q.displayed_to_user?(log) && !q.derived?) || q.has_inferred_check_answers_value_or_is_derived?(log)
    end
  end

  def displayed_in_tasklist?(_log)
    true
  end
end
