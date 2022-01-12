class Form::Page
  attr_accessor :id, :header, :description, :questions, :soft_validations,
                :depends_on, :subsection, :hide_subsection_label

  def initialize(id, hsh, subsection)
    @id = id
    @header = hsh["header"]
    @description = hsh["description"]
    @questions = hsh["questions"].map { |q_id, q| Form::Question.new(q_id, q, self) }
    @depends_on = hsh["depends_on"]
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

private

  def depends_on_met(case_log)
    return true unless depends_on

    depends_on.all? do |question, value|
      !case_log[question].nil? && case_log[question] == value
    end
  end
end
