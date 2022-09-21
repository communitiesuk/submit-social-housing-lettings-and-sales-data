class Form::Lettings::Pages::Renewal < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "renewal"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::Renewal.new(nil, nil, self),
    ]
  end
end
