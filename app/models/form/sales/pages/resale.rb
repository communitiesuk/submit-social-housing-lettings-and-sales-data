class Form::Sales::Pages::Resale < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "resale"
    @subsection = subsection
    @depends_on = [
      {
        "staircase" => 2,
      },
      {
        "staircase" => 3,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Resale.new(nil, nil, self),
    ]
  end
end
