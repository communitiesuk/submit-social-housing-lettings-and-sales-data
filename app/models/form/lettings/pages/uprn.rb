class Form::Lettings::Pages::Uprn < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::Uprn.new(nil, nil, self),
    ]
  end

  def routed_to?(_log, _current_user)
    true
  end
end
