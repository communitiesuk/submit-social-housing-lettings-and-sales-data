class Form::Sales::Pages::DepositDiscount < ::Form::Page
  def initialize(id, hsh, subsection, optional:)
    super(id, hsh, subsection)
    @optional = optional
    @header = "About the deposit"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositDiscount.new(nil, nil, self),
    ]
  end

  def depends_on
    if form.start_year_after_2024?
      [{ "social_homebuy?" => true, "stairowned_100?" => @optional }]
    else
      [{ "social_homebuy?" => true }]
    end
  end
end
