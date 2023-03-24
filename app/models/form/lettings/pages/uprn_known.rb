class Form::Lettings::Pages::UprnKnown < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn_known"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::UprnKnown.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user = nil)
    !log.is_supported_housing?
  end
end
