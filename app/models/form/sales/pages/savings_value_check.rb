class Form::Sales::Pages::SavingsValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      {
        "savings_over_soft_max?" => true,
      },
    ]
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::SavingsValueCheck.new(nil, nil, self),
    ]
  end
end
