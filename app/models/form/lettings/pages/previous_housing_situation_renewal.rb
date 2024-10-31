class Form::Lettings::Pages::PreviousHousingSituationRenewal < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_housing_situation_renewal"
    @copy_key = "lettings.household_situation.prevten.renewal"
    @depends_on = [{ "is_renewal?" => true, "is_supported_housing?" => true }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PreviousTenureRenewal.new(nil, nil, self)]
  end
end
