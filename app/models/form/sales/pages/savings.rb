class Form::Sales::Pages::Savings < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "savings"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::SavingsNk.new(nil, nil, self),
      Form::Sales::Questions::Savings.new(nil, nil, self),
    ]
  end
end
