class Form::Lettings::Pages::ReasonablePreference < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "reasonable_preference"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Reasonpref.new(nil, nil, self)]
  end
end
