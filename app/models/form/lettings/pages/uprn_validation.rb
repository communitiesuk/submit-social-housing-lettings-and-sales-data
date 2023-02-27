class Form::Lettings::Pages::UprnValidation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn_validation"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::UprnValidation.new(nil, nil, self),
    ]
  end

  def routed_to?(_log, _current_user)
    true
  end
end
