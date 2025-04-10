class Form::Sales::Pages::UprnConfirmation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn_confirmation"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::UprnConfirmation.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user = nil)
    log.uprn.present? && log.uprn_known == 1
  end
end
