class Form::Page
  attr_accessor :id, :header, :description, :questions, :derived,
                :depends_on, :title_text, :informative_text, :subsection, :hide_subsection_label

  def initialize(id, hsh, subsection)
    @id = id
    @header = hsh["header"]
    @description = hsh["description"]
    @questions = hsh["questions"].map { |q_id, q| Form::Question.new(q_id, q, self) }
    @depends_on = hsh["depends_on"]
    @derived = hsh["derived"]
    @title_text = hsh["title_text"]
    @informative_text = hsh["informative_text"]
    @hide_subsection_label = hsh["hide_subsection_label"]
    @subsection = subsection
  end

  delegate :form, to: :subsection

  def routed_to?(case_log)
    transaction = Sentry.get_current_scope&.get_transaction
    span = transaction&.start_child(op: :routed_to?)

    return true unless depends_on || subsection.depends_on
    routed_to = subsection.enabled?(case_log) && form.depends_on_met(depends_on, case_log)

    span&.finish
    routed_to
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
end
