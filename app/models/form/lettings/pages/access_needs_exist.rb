class Form::Lettings::Pages::AccessNeedsExist < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "access_needs_exist"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Housingneeds.new(nil, nil, self)]
  end
end
