class Form::Lettings::Pages::Uprn < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::UprnKnown.new(nil, nil, self),
      Form::Lettings::Questions::Uprn.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user = nil)
    !log.is_supported_housing?
  end

  def skip_text
    "Enter address instead"
  end

  def skip_href(log = nil)
    return unless log

    "/#{log.model_name.param_key.dasherize}s/#{log.id}/address"
  end
end
