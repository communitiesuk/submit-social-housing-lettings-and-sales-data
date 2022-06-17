class Form::Setup::Pages::Renewal < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "renewal"
    @header = ""
    @description = ""
    @questions = questions
    @subsection = subsection
  end

  def questions
    [
      Form::Setup::Questions::Renewal.new(nil, nil, self),
    ]
  end
end
