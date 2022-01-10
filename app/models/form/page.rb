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

  def is_22_23_log?(startdate)
    return false if startdate.blank?

    startdate.to_date > Date.parse("2022-04-01") && startdate.to_date < Date.parse("2023-04-01")
  end

  def routed_to?(case_log)
    return true unless depends_on

    depends_on.all? do |question, value|
      !case_log[question].nil? && case_log[question] == value
    end
  end
end
