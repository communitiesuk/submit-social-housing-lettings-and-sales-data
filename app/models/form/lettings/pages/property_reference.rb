class Form::Lettings::Pages::PropertyReference < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_reference"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::PropertyReference.new(nil, nil, self),
    ]
  end
end
