class Form::Page
  attr_accessor :id, :header, :description, :questions, :soft_validations,
                :depends_on, :title_text, :informative_text, :subsection, :hide_subsection_label

  def initialize(id, hsh, subsection)
    @id = id
    @header = hsh["header"]
    @description = hsh["description"]
    @questions = hsh["questions"].map { |q_id, q| Form::Question.new(q_id, q, self) }
    @depends_on = hsh["depends_on"]
    @title_text = hsh["title_text"]
    @informative_text = hsh["informative_text"]
    @hide_subsection_label = hsh["hide_subsection_label"]
    @soft_validations = hsh["soft_validations"]&.map { |sv_id, s| Form::Question.new(sv_id, s, self) }
    @subsection = subsection
  end

  def expected_responses
    questions + (soft_validations || [])
  end

  def has_soft_validations?
    soft_validations.present?
  end

  def routed_to?(case_log)
    return true unless depends_on || subsection.depends_on

    subsection.enabled?(case_log) && depends_on_met(case_log)
  end

  def non_conditional_questions
    @non_conditional_questions ||= questions.reject do |q|
      conditional_question_ids.include?(q.id)
    end
  end

private

  def conditional_question_ids
    @conditional_question_ids ||= questions.flat_map { |q|
      next if q.conditional_for.blank?

      # TODO: remove this condition once all conditional questions no longer need JS
      q.conditional_for.keys if q.type == "radio"
    }.compact
  end

  def send_chain(arr, case_log)
    Array(arr).inject(case_log) { |o, a| o.public_send(*a) }
  end

  def depends_on_met(case_log)
    return true unless depends_on

    depends_on.any? do |conditions_set|
      conditions_set.all? do |question, value|
        parts = question.split(".")
        case_log_value = send_chain(parts, case_log)

        value.nil? ? case_log_value == value : !case_log_value.nil? && case_log_value == value
      end
    end
  end
end
