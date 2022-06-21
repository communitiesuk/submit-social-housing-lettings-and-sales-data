class Form::Setup::Pages::CreatedBy < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "created_by"
    @header = ""
    @description = ""
    @questions = questions
    @subsection = subsection
  end

  def questions
    [
      Form::Setup::Questions::CreatedById.new(nil, nil, self),
    ]
  end

  def routed_to?(_case_log, current_user)
    !!current_user&.support?
  end
end
