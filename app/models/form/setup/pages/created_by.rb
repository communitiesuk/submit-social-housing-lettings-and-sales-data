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

  def routed_to?(_case_log)
    !!form.current_user&.support?
  end

  def invalidated?(_case_log)
    false
  end
end
