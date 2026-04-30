class Form::Sales::Pages::DepositDiscount < ::Form::Page
  def initialize(id, hsh, subsection, optional:)
    super(id, hsh, subsection)
    @optional = optional
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositDiscount.new(nil, nil, self),
    ]
  end

  def depends_on
    [{ "social_homebuy?" => true, "stairowned_100?" => @optional }]
  end
end
