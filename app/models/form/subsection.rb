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

  def enabled?(lettings_log)
    return true unless depends_on

    depends_on.any? do |conditions_set|
      conditions_set.all? do |subsection_id, dependent_status|
        form.get_subsection(subsection_id).status(lettings_log) == dependent_status.to_sym
      end
    end
  end

  def status(lettings_log)
    unless enabled?(lettings_log)
      return :cannot_start_yet
    end

    qs = applicable_questions(lettings_log)
    qs_optional_removed = qs.reject { |q| lettings_log.optional_fields.include?(q.id) }
    return :not_started if lettings_log.id.nil?
    return :in_progress if qs.count.positive? && qs.all? { |question| lettings_log[question.id].blank? || question.read_only? || question.derived? }
    return :completed if qs_optional_removed.all? { |question| question.completed?(lettings_log) }

    :in_progress
  end

  def is_incomplete?(lettings_log)
    %i[not_started in_progress].include?(status(lettings_log))
  end

  def is_started?(lettings_log)
    %i[in_progress completed].include?(status(lettings_log))
  end

  def applicable_questions(lettings_log)
    questions.select do |q|
      (q.displayed_to_user?(lettings_log) && !q.derived?) || q.has_inferred_check_answers_value?(lettings_log)
    end
  end
end
