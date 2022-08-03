class Form::Setup::Pages::Renewal < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "renewal"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Setup::Questions::Renewal.new(nil, nil, self),
    ]
  end
end
