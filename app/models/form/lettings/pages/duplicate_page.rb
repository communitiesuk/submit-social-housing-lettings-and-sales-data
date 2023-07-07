class Form::Lettings::Pages::DuplicatePage < ::Form::Page
  def initialize(id, hsh, section)
    super
    @page_type = "duplicate"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Duplicate.new(nil, nil, self)]
  end
end
