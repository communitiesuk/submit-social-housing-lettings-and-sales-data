class Form::Lettings::Pages::PreviousHousingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_housing_situation"
    @depends_on = [{ "renewal" => 0 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Prevten.new(nil, nil, self)]
  end
end
