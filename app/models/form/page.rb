class Form::Page
  attr_accessor :id, :header, :description, :questions, :soft_validations,
                :depends_on, :subsection

  def initialize(id, hsh, subsection)
    @id = id
    @header = hsh["header"]
    @description = hsh["description"]
    @questions = hsh["questions"].map { |q_id, q| Form::Question.new(q_id, q, self) }
    @depends_on = hsh["depends_on"]
    @soft_validations = hsh["soft_validations"]&.map { |v_id, s| Form::Question.new(v_id, s, self) }
    @subsection = subsection
  end

  def expected_responses
    questions + (soft_validations || [])
  end

  def has_soft_validations?
    soft_validations.present?
  end

  def routed_to?(case_log)
    return true unless depends_on

    depends_on.all? do |question, value|
      case_log[question].present? && case_log[question] == value
    end
  end
end
