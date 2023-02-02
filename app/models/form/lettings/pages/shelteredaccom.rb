class Form::Lettings::Pages::Shelteredaccom < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "shelteredaccom"
    @depends_on = [{ "needstype" => 2 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Sheltered.new(nil, nil, self)]
  end
end
