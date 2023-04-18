class Form::Sales::Pages::Uprn < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::UprnKnown.new(nil, nil, self),
      Form::Sales::Questions::Uprn.new(nil, nil, self),
    ]
  end

  def skip_text
    "Enter address instead"
  end

  def skip_href(log = nil)
    return unless log

    "/#{log.model_name.param_key.dasherize}s/#{log.id}/address"
  end
end
