class Form::Common::Pages::CreatedBy < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "created_by"
  end

  def questions
    @questions ||= [
      Form::Common::Questions::CreatedById.new(nil, nil, self),
    ]
  end

  def routed_to?(_log, current_user)
    !!current_user&.support?
  end
end
