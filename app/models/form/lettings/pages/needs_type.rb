class Form::Lettings::Pages::NeedsType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "needs_type"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::NeedsType.new(nil, nil, self),
    ]
  end
end
