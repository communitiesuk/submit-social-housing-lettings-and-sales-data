class Form::Sales::Pages::LastAccommodation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "last_accommodation"
    @copy_key = "sales.household_situation.last_accommodation"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PreviousPostcodeKnown.new(nil, nil, self),
      Form::Sales::Questions::PreviousPostcode.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _user)
    return false if form.start_year_after_2024? && log.discounted_ownership_sale?

    super
  end
end
