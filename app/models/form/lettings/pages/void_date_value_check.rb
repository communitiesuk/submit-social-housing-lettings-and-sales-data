class Form::Lettings::Pages::VoidDateValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "void_date_value_check"
    @depends_on = [{ "voiddate_in_soft_range?" => true }]
    @title_text = { "translation" => "soft_validations.void_date.title_text" }
    @informative_text = {}
  end

  def questions
    @questions ||= [Form::Lettings::Questions::VoidDateValueCheck.new(nil, nil, self)]
  end
end
