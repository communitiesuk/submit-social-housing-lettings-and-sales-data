class Form::Lettings::Pages::PreviousHousingSituationRenewal < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_housing_situation_renewal"
    @header = ""
    @depends_on = [{ "renewal" => 1, "needstype" => 2 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Prevten.new(nil, nil, self)]
  end
end
