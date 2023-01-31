class Form::Sales::Pages::MortgageValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index = nil)
    super(id, hsh, subsection)
    @depends_on = depends_on
    @informative_text = {}
    @person_index = person_index
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
          "jointpur" => 1,
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
end
