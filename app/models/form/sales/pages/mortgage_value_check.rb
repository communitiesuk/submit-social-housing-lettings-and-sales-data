class Form::Sales::Pages::MortgageValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index = nil)
    super(id, hsh, subsection)
    @depends_on = depends_on
    @informative_text = {}
    @person_index = person_index
    @title_text = { "translation" => "soft_validations.mortgage.title_text" }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageValueCheck.new(nil, nil, self),
    ]
  end

  def depends_on
    if @person_index == 2
      [
        {
          "mortgage_over_soft_max?" => true,
          "joint_purchase?" => true,
        },
      ]
    else
      [
        {
          "mortgage_over_soft_max?" => true,
        },
      ]
    end
  end

  def affected_question_ids
    %w[mortgage inc1mort inc2mort jointpur income1 income2 inc1mort inc2mort]
  end
end
