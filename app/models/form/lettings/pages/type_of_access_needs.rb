class Form::Lettings::Pages::TypeOfAccessNeeds < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "type_of_access_needs"
    @header = "Disabled access needs"
    @depends_on = [{ "housingneeds" => 1 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::HousingneedsType.new(nil, nil, self), Form::Lettings::Questions::HousingneedsOther.new(nil, nil, self)]
  end
end
