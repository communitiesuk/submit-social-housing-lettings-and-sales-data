class Form::Lettings::Pages::VoidDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "void_date"
    @depends_on = [{ "is_renewal?" => false }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Voiddate.new(nil, nil, self)]
  end
end
