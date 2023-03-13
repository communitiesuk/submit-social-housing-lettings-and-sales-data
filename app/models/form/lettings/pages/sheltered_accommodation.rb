class Form::Lettings::Pages::ShelteredAccommodation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "sheltered_accommodation"
    @depends_on = [{ "is_supported_housing?" => true }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Sheltered.new(nil, nil, self)]
  end
end
