class Form::Sales::Pages::Deposit < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:, optional:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @optional = optional
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self, ownershipsch: @ownershipsch, optional: @optional),
    ]
  end

  def depends_on
    if form.start_year_after_2024?
      [{ "social_homebuy?" => false, "ownershipsch" => 1, "stairowned_100?" => @optional },
       { "ownershipsch" => 2 },
       { "ownershipsch" => 3, "mortgageused" => 1 },
       { "social_homebuy?" => true, "stairowned_100?" => @optional }]
    else
      [{ "social_homebuy?" => false, "ownershipsch" => 1 },
       { "ownershipsch" => 2 },
       { "ownershipsch" => 3, "mortgageused" => 1 },
       { "social_homebuy?" => true }]
    end
  end
end
