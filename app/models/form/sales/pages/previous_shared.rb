class Form::Sales::Pages::PreviousShared < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_shared"
    @depends_on = [
      { "prevown" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Prevshared.new(nil, nil, self),
    ]
  end
end
