class Form::Sales::Pages::DepositValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @subsection = subsection
    @depends_on = [
      {
        "deposit_over_soft_max?" => true,
      },
    ]
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositValueCheck.new(nil, nil, self),
    ]
  end
end
