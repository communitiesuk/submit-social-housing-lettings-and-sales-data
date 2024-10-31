class Form::Sales::Pages::LastAccommodationLa < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "last_accommodation_la"
    @copy_key = "sales.household_situation.last_accommodation_la"
    @depends_on = [{
      "is_previous_la_inferred" => false,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PreviousLaKnown.new(nil, nil, self),
      Form::Sales::Questions::Prevloc.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _user)
    return false if form.start_year_after_2024? && log.discounted_ownership_sale?

    super
  end
end
