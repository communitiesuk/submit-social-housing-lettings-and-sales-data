class Form::Lettings::Pages::TypeOfAccessNeeds < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "type_of_access_needs"
    @copy_key = "lettings.household_needs.housingneeds_type"
    @depends_on = [{ "housingneeds" => 1 }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::HousingneedsType.new(nil, nil, self),
      Form::Lettings::Questions::HousingneedsOther.new(nil, nil, self),
    ]
  end
end
