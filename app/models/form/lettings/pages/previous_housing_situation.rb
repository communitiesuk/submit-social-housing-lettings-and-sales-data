class Form::Lettings::Pages::PreviousHousingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_housing_situation"
    @depends_on = [{ "is_renewal?" => false }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PreviousTenure.new(nil, nil, self)]
  end
end
