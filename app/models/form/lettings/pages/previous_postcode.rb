class Form::Lettings::Pages::PreviousPostcode < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_postcode"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Ppcodenk.new(nil, nil, self), Form::Lettings::Questions::PpostcodeFull.new(nil, nil, self)]
  end
end
