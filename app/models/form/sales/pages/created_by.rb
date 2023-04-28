class Form::Sales::Pages::CreatedBy < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "created_by"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::CreatedById.new(nil, nil, self),
    ]
  end

  def routed_to?(_log, current_user)
    return true if current_user&.support?
    return true if current_user&.data_coordinator?

    false
  end
end
