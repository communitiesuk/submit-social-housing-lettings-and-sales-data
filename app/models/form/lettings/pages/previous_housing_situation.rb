class Form::Lettings::Pages::PreviousHousingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_housing_situation"
    @copy_key = "lettings.household_situation.prevten.not_renewal"
    @depends_on = [{ "is_renewal?" => false }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PreviousTenure.new(nil, nil, self)]
  end
end
