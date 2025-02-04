class Form::Page
  attr_accessor :id, :header_partial, :description, :questions, :depends_on, :title_text,
                :informative_text, :subsection, :hide_subsection_label, :next_unresolved_page_id,
                :skip_text, :interruption_screen_question_ids, :submit_text, :question_number

  def initialize(id, hsh, subsection)
    @id = id
    @subsection = subsection
    if hsh
      @header = hsh["header"]
      @header_partial = hsh["header_partial"]
      @description = hsh["description"]
      @questions = hsh["questions"].map { |q_id, q| Form::Question.new(q_id, q, self) }
      @question_number = hsh["question_number"]
      @depends_on = hsh["depends_on"]
      @title_text = hsh["title_text"]
      @informative_text = hsh["informative_text"]
      @hide_subsection_label = hsh["hide_subsection_label"]
      @next_unresolved_page_id = hsh["next_unresolved_page_id"]
      @skip_text = hsh["skip_text"]
      @submit_text = hsh["submit_text"]
      @interruption_screen_question_ids = hsh["interruption_screen_question_ids"] || []
    end
  end

  delegate :form, to: :subsection

  def copy_key
    @copy_key ||= "#{form.type}.#{subsection.copy_key}.#{questions[0].id}"
  end

  def header
    @header ||= I18n.t("forms.#{form.start_date.year}.#{copy_key}.page_header", default: "")
  end

  def routed_to?(log, _current_user)
    return true unless depends_on || subsection.depends_on

    subsection.enabled?(log) && form.depends_on_met(depends_on, log)
  end

  def non_conditional_questions
    @non_conditional_questions ||= questions.reject do |q|
      conditional_question_ids.include?(q.id)
    end
  end

  def has_unanswered_questions?(log)
    questions.any? { |question| question.displayed_to_user?(log) && question.unanswered?(log) }
  end

  def interruption_screen?
    questions.all? { |question| question.type == "interruption_screen" }
  end

  def skip_href(log = nil); end

private

  def conditional_question_ids
    @conditional_question_ids ||= questions.flat_map { |q|
      next if q.conditional_for.blank?

      # TODO: remove this condition once all conditional questions no longer need JS
      q.conditional_for.keys if q.type == "radio"
    }.compact
  end
end
