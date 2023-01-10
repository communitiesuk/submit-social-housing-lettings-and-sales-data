class Form::Lettings::Pages::CreatedBy < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "created_by"
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::CreatedById.new(nil, nil, self),
    ]
  end

  def routed_to?(_log, current_user)
    !!current_user&.support?
  end
end
