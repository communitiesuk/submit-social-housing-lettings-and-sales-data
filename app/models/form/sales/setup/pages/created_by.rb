class Form::Setup::Pages::CreatedBy < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "created_by"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Setup::Questions::CreatedById.new(nil, nil, self),
    ]
  end
end
