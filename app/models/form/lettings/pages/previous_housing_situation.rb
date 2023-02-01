class Form::Lettings::Pages::PreviousHousingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_housing_situation"
    @header = ""
    @depends_on = [{ "renewal" => 0 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Prevten.new(nil, nil, self)]
  end
end
